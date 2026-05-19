qml_module(ZShell-blobs
	URI ZShell.Blobs
    SOURCES
        blobgroup.cpp
        blobshape.cpp
        blobrect.cpp
        blobinvertedrect.cpp
        blobmaterial.cpp
    LIBRARIES
        Qt::Quick
)

qt_add_shaders(ZShell-blobs "blob_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
	GLSL "300es,330"
    PREFIX "/"
    FILES
        shaders/blob.frag
        shaders/blob.vert
)
