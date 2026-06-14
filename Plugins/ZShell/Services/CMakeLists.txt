qml_module(ZShell-services
	URI ZShell.Services
	SOURCES
		service.hpp service.cpp
		serviceref.hpp serviceref.cpp
		beattracker.hpp beattracker.cpp
		audiocollector.hpp audiocollector.cpp
		audioprovider.hpp audioprovider.cpp
		cavaprovider.hpp cavaprovider.cpp
		desktopmodel.hpp desktopmodel.cpp
		desktopstatemanager.hpp desktopstatemanager.cpp
		hyprsunsetmanager.hpp hyprsunsetmanager.cpp
		tickingservice.hpp tickingservice.cpp
		sensorslib.hpp sensorslib.cpp
		usagefmt.hpp usagefmt.cpp
		cpu.hpp cpu.cpp
		memory.hpp memory.cpp
		diskinfo.hpp diskinfo.cpp
		storage.hpp storage.cpp
	LIBRARIES
		Qt6::Core
		Qt6::Qml
		PkgConfig::Pipewire
		PkgConfig::Aubio
		PkgConfig::Cava
		Sensors::Sensors
)
