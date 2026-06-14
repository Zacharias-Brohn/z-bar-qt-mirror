qml_module(ZShell-internal
	URI ZShell.Internal
	SOURCES
		hyprextras.hpp hyprextras.cpp
		hyprdevices.hpp hyprdevices.cpp
		cachingimagemanager.hpp cachingimagemanager.cpp
		circularindicatormanager.hpp circularindicatormanager.cpp
		circularbuffer.hpp circularbuffer.cpp
		sparklineitem.hpp sparklineitem.cpp
		arcgauge.hpp arcgauge.cpp
		wallpaperimage.hpp wallpaperimage.cpp
		lidwatcher.hpp lidwatcher.cpp
		visualizerbars.hpp visualizerbars.cpp
		linearindicatormanager.hpp linearindicatormanager.cpp
	LIBRARIES
		Qt::Gui
		Qt::Quick
		Qt::Concurrent
		Qt::Core
		Qt::Network
		Qt::DBus
)
