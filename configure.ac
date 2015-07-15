AC_PREREQ(2.61)
AC_INIT([ros3d-stream], [0.1.0], [ros3d@open-rnd.pl])
AC_CONFIG_SRCDIR([src/main.vala])
AC_CONFIG_AUX_DIR([.])
AC_PROG_MAKE_SET
AM_PROG_LIBTOOL
AM_INIT_AUTOMAKE([tar-pax foreign subdir-objects])
AM_SILENT_RULES([yes])

AM_MAINTAINER_MODE

# Checks for header files.
# AC_HEADER_STDC
# AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
# AC_C_CONST

# Checks for programs.
AC_PROG_CC
AM_PROG_VALAC([0.7.0])
AC_PROG_INSTALL

AC_SUBST(ROS3D_STREAM_VALAFLAGS, ["--pkg=libsoup-2.4"])
# AC_SUBST(MCONNECT_VALAFLAGS, [--pkg=json-glib-1.0 --pkg=gee-0.8])
PKG_CHECK_MODULES(ROS3D_STREAM, [glib-2.0
                               gobject-2.0
                               gio-2.0
                               gio-unix-2.0
                               libsoup-2.4
                               ])
AC_SUBST(ROS3D_STREAM_CFLAGS)
AC_SUBST(ROS3D_STREAM_LIBS)

# Files to generate
AC_CONFIG_FILES([Makefile])

# Output
AC_OUTPUT
