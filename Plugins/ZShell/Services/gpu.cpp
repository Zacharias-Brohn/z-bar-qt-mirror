#include "gpu.hpp"

#include "sensorslib.hpp"

#include <cmath>
#include <qcontainerfwd.h>
#include <qdir.h>
#include <qfile.h>
#include <qobject.h>
#include <qregularexpression.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QFileSystemWatcher>
#include <QTimer>

namespace ZShell::services {

namespace {

constexpr const char* kTypeDetectScript =
	"if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null "
	"2>&1; then echo NVIDIA;"
	" elif ls /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | grep "
	"-q .; then echo GENERIC;"
	" else echo NONE; fi";

constexpr const char* kNameDetectScript =
	"nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null"
	" || glxinfo -B 2>/dev/null | grep 'Device:' | cut -d':' -f2 | cut -d'(' "
	"-f1"
	" || lspci 2>/dev/null | grep -i 'vga\\|3d controller\\|display' | head -1";

} // namespace

Gpu::Gpu(QObject* parent) : TickingService(parent) {
	QString configPath =
		QDir::homePath() + QStringLiteral("/.config/zshell/config.json");

	auto reloadConfig = [this, configPath]() {
		QFile file(configPath);
		if (file.open(QIODevice::ReadOnly)) {
			QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
			if (!doc.isNull()) {
				QJsonObject services =
					doc.object().value("services").toObject();
				setUserType(parseType(services.value("gpuType").toString()));
			}
		}
	};

	reloadConfig();

	static QFileSystemWatcher* watcher = new QFileSystemWatcher();
	if (!watcher->files().contains(configPath)) {
		QObject::connect(
			watcher,
			&QFileSystemWatcher::fileChanged,
			this,
			[this, configPath]() {
				QTimer::singleShot(100, this, [this, configPath]() {
					QFile file(configPath);
					if (file.exists()) {
						QJsonDocument doc =
							QJsonDocument::fromJson(file.readAll());
						if (!doc.isNull()) {
							QJsonObject services =
								doc.object().value("services").toObject();
							setUserType(parseType(
								services.value("gpuType").toString()));
						}
					}
				});
			});
		watcher->addPath(configPath);
	}

	// Detection must run before any ServiceRef appears: callers may gate the ref on
	// `type !== Gpu.None`, which would otherwise deadlock the detection.
	if (m_userType == Auto) {
		detectTypeOnce();
	}
	detectNameOnce();
}

Gpu::Type Gpu::type() const {
	return m_userType == Auto ? m_autoType : m_userType;
}

Gpu::Type Gpu::userType() const {
	return m_userType;
}

Gpu::Type Gpu::autoType() const {
	return m_autoType;
}

QString Gpu::name() const {
	return m_name;
}

qreal Gpu::percentage() const {
	return m_percentage;
}

qreal Gpu::temperature() const {
	return m_temperature;
}

qreal Gpu::memoryUsed() const {
	return m_memoryUsed;
}

qreal Gpu::memoryTotal() const {
	return m_memoryTotal;
}

void Gpu::setUserType(Type value) {
	if (value == m_userType) {
		return;
	}
	const Type prevDerived = type();
	m_userType = value;
	Q_EMIT userTypeChanged();
	if (type() != prevDerived) {
		Q_EMIT typeChanged();
	}
}

void Gpu::setAutoType(Type value) {
	if (value == m_userType) {
		return;
	}
	const Type prevDerived = type();
	m_autoType = value;
	Q_EMIT autoTypeChanged();
	if (type() != prevDerived) {
		Q_EMIT typeChanged();
	}
}

void Gpu::setName(QString value) {
	if (value == m_name) {
		return;
	}
	m_name = std::move(value);
	Q_EMIT nameChanged();
}

void Gpu::setMemoryUsed(qreal value) {
	if (std::abs(m_memoryUsed - value) < 0.001) return;
	m_memoryUsed = value;
	Q_EMIT memoryUsedChanged();
}

void Gpu::setMemoryTotal(qreal value) {
	if (std::abs(m_memoryTotal - value) < 0.001) return;
	m_memoryTotal = value;
	Q_EMIT memoryTotalChanged();
}

void Gpu::tick() {
	const Type t = type();
	if (t == Generic) {
		readGenericUsage();
		readGpuTemperature();
	} else if (t == Nvidia) {
		startNvidiaUsage();
	} else {
		if (std::abs(m_percentage) > 0.0001) {
			m_percentage = 0.0;
			Q_EMIT percentageChanged();
		}
		if (std::abs(m_temperature) > 0.05) {
			m_temperature = 0.0;
			Q_EMIT temperatureChanged();
		}
	}
}

void Gpu::detectTypeOnce() {
	if (m_typeProc) {
		return;
	}
	m_typeProc = new QProcess(this);
	QObject::connect(
		m_typeProc,
		&QProcess::finished,
		this,
		[this](int, QProcess::ExitStatus) {
			const QByteArray out =
				m_typeProc->readAllStandardOutput().trimmed();
			if (!out.isEmpty()) {
				setAutoType(parseType(QString::fromLatin1(out)));
			}
			m_typeProc->deleteLater();
			m_typeProc = nullptr;
		});
	m_typeProc->start(
		QStringLiteral("sh"),
		{QStringLiteral("-c"), QString::fromLatin1(kTypeDetectScript)});
}

void Gpu::detectNameOnce() {
	if (m_nameProc) {
		return;
	}
	m_nameProc = new QProcess(this);
	QObject::connect(
		m_nameProc,
		&QProcess::finished,
		this,
		[this](int, QProcess::ExitStatus) {
			const QString output =
				QString::fromUtf8(m_nameProc->readAllStandardOutput()).trimmed();
			if (!output.isEmpty()) {
				const QString lower = output.toLower();
				if (lower.contains(QStringLiteral("nvidia")) ||
					lower.contains(QStringLiteral("geforce")) ||
					lower.contains(QStringLiteral("rtx")) ||
					lower.contains(QStringLiteral("gtx")) ||
					lower.contains(QStringLiteral("rx"))) {
					setName(cleanName(output));
				} else {
					static const QRegularExpression bracketRe(
						QStringLiteral("\\[([^\\]]+)\\][^\\[]*$"));
					const auto bracket = bracketRe.match(output);
					if (bracket.hasMatch()) {
						setName(cleanName(bracket.captured(1)));
					} else {
						static const QRegularExpression colonRe(
							QStringLiteral(":\\s*(.+)"));
						const auto colon = colonRe.match(output);
						if (colon.hasMatch()) {
							setName(cleanName(colon.captured(1)));
						}
					}
				}
			}
			m_nameProc->deleteLater();
			m_nameProc = nullptr;
		});
	m_nameProc->start(
		QStringLiteral("sh"),
		{QStringLiteral("-c"), QString::fromLatin1(kNameDetectScript)});
}

void Gpu::readGenericMemory() {
	const QStringList paths = QDir(QStringLiteral("/sys/class/drm"))
								  .entryList(
									  QStringList() << QStringLiteral("card*"),
									  QDir::Dirs | QDir::NoDotAndDotDot);

	qreal totalMem = 0.0;
	qreal usedMem = 0.0;
	for (const QString& card : paths) {
		QFile total(
			QStringLiteral("/sys/class/drm/%1/device/mem_info_vram_total")
				.arg(card));
		if (!total.open(QIODevice::ReadOnly | QIODevice::Text)) {
			continue;
		}
		bool ok = false;
		const qreal v = total.readAll().trimmed().toDouble(&ok);
		total.close();
		if (ok) {
			totalMem += v;
		}

		QFile used(QStringLiteral("/sys/class/drm/%1/device/mem_info_vram_used")
					   .arg(card));
		if (!used.open(QIODevice::ReadOnly | QIODevice::Text)) {
			continue;
		}
		bool ok1 = false;
		const qreal v1 = used.readAll().trimmed().toDouble(&ok1);
		used.close();
		if (ok1) {
			usedMem += v1;
		}
	}

	setMemoryTotal(totalMem);
	setMemoryUsed(usedMem);
}

void Gpu::readGenericUsage() {
	const QStringList paths = QDir(QStringLiteral("/sys/class/drm"))
								  .entryList(
									  QStringList() << QStringLiteral("card*"),
									  QDir::Dirs | QDir::NoDotAndDotDot);
	qreal sum = 0.0;
	int count = 0;
	for (const QString& card : paths) {
		QFile f(QStringLiteral("/sys/class/drm/%1/device/gpu_busy_percent")
					.arg(card));
		if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
			continue;
		}
		bool ok = false;
		const qreal v = f.readAll().trimmed().toDouble(&ok);
		f.close();
		if (ok) {
			sum += v;
			++count;
		}
	}
	const qreal newPerc = count > 0 ? sum / count / 100.0 : 0.0;
	if (std::abs(newPerc - m_percentage) > 0.0001) {
		m_percentage = newPerc;
		Q_EMIT percentageChanged();
	}
}

void Gpu::startNvidiaUsage() {
	if (m_nvidiaProc) {
		return;
	}
	m_nvidiaProc = new QProcess(this);
	QObject::connect(
		m_nvidiaProc, &QProcess::readyReadStandardOutput, this, [this]() {
			while (m_nvidiaProc->canReadLine()) {
				const QByteArray out = m_nvidiaProc->readLine();
				const QString output = QString::fromUtf8(out).trimmed();
				if (output.isEmpty()) continue;

				const QList<QString> parts = output.split(',');
				if (parts.size() < 4) return;

				bool ok1 = false;
				bool ok2 = false;
				bool ok3 = false;
				bool ok4 = false;
				const qreal usage =
					parts.at(0).trimmed().toDouble(&ok1) / 100.0;
				const qreal temp = parts.at(1).trimmed().toDouble(&ok2);
				const qreal memUsed = parts.at(2).trimmed().toDouble(&ok3);
				const qreal memTotal = parts.at(3).trimmed().toDouble(&ok4);

				if (ok1 && std::abs(usage - m_percentage) > 0.0001) {
					m_percentage = usage;
					Q_EMIT percentageChanged();
				}
				if (ok2 && std::abs(temp - m_temperature) > 0.05) {
					m_temperature = temp;
					Q_EMIT temperatureChanged();
				}
				if (ok3) {
					setMemoryUsed(memUsed);
				}
				if (ok4) {
					setMemoryTotal(memTotal);
				}
			}
		});

	QObject::connect(m_nvidiaProc, &QProcess::finished, this, [this]() {
		m_nvidiaProc->deleteLater();
		m_nvidiaProc = nullptr;
	});

	QObject::connect(
		m_nvidiaProc,
		&QProcess::errorOccurred,
		this,
		[this](QProcess::ProcessError) {
			m_nvidiaProc->deleteLater();
			m_nvidiaProc = nullptr;
		});

	m_nvidiaProc->start(
		QStringLiteral("nvidia-smi"),
		{QStringLiteral(
			 "--query-gpu=utilization.gpu,temperature.gpu,"
			 "memory.used,memory.total"),
		 QStringLiteral("--format=csv,noheader,nounits"),
		 QStringLiteral("-lms"),
		 QString::number(updateInterval())});
}

void Gpu::readGpuTemperature() {
	const auto t = sensorslib::gpuPciAverageTemp();
	const qreal newTemp = t.value_or(0.0);
	if (std::abs(newTemp - m_temperature) > 0.05) {
		m_temperature = newTemp;
		Q_EMIT temperatureChanged();
	}
}

Gpu::Type Gpu::parseType(const QString& s) {
	const QString u = s.trimmed().toUpper();
	if (u.isEmpty()) {
		return Auto;
	}
	if (u == QStringLiteral("NVIDIA")) {
		return Nvidia;
	}
	if (u == QStringLiteral("GENERIC")) {
		return Generic;
	}
	return None;
}

QString Gpu::cleanName(QString s) {
	static const QRegularExpression noise(
		QStringLiteral("\\(R\\)|\\(TM\\)|Graphics"),
		QRegularExpression::CaseInsensitiveOption);
	static const QRegularExpression spaces(QStringLiteral("\\s+"));
	s.replace(noise, QString());
	s.replace(spaces, QStringLiteral(" "));
	return s.trimmed();
}

} // namespace ZShell::services
