configdir = ${sysconfdir}/ros3d-stream

bin_PROGRAMS = ros3d-stream

ros3d_stream_SOURCES = \
	src/main.vala \
	src/stream.vala \
	src/httpapi.vala \
	src/config.vala

ros3d_stream_LDADD = $(ROS3D_STREAM_LIBS)
ros3d_stream_CFLAGS = $(ROS3D_STREAM_CFLAGS) -Isrc

VALAFLAGS = $(ROS3D_STREAM_VALAFLAGS) --no-color

config_DATA = ros3d-stream.conf

BUILT_SOURCES=$(ros3d_stream_SOURCES:.vala=.c)
CLEANFILES = $(BUILT_SOURCES)

