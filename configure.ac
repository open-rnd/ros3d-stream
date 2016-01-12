# Copyright (c) 2015 Open-RnD
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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

AC_SUBST(ROS3D_STREAM_VALAFLAGS, ["--pkg=libsoup-2.4 --pkg=gstreamer-1.0 --pkg=avahi-gobject --pkg=avahi-client"])

PKG_CHECK_MODULES(ROS3D_STREAM, [glib-2.0
                               gobject-2.0
                               gio-2.0
                               gio-unix-2.0
                               libsoup-2.4
                               gstreamer-1.0
                               avahi-gobject
                               avahi-client
                               ])
AC_SUBST(ROS3D_STREAM_CFLAGS)
AC_SUBST(ROS3D_STREAM_LIBS)

# Files to generate
AC_CONFIG_FILES([Makefile])

# Output
AC_OUTPUT
