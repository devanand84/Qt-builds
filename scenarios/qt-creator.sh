#!/bin/bash

#
# The BSD 3-Clause License. http://www.opensource.org/licenses/BSD-3-Clause
#
# This file is part of 'Qt-builds' project.
# Copyright (c) 2013 by Alexpux (alexpux@gmail.com)
# All rights reserved.
#
# Project: Qt-builds ( https://github.com/Alexpux/Qt-builds )
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# - Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the distribution.
# - Neither the name of the 'Qt-builds' nor the names of its contributors may
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# **************************************************************************

P=qt-creator
P_V=${P}-${QT_CREATOR_VERSION}-src
SRC_FILE="${P_V}.tar.gz"
URL=http://releases.qt-project.org/qtcreator/${QT_CREATOR_VERSION}/${SRC_FILE}
DEPENDS=(qt5)

src_download() {
	func_download $P_V ".tar.gz" $URL
}

src_unpack() {
	func_uncompress $P_V ".tar.gz"
}

src_patch() {
	local _patches=(
		$P/mingw-gcc47.patch
	)
	
	func_apply_patches \
		$P_V \
		_patches[@]
}

src_configure() {
	mkdir -p $BUILD_DIR/build-${P_V}
	pushd $BUILD_DIR/build-${P_V}
	
	local _rel_path=$( func_absolute_to_relative $BUILD_DIR/build-${P_V} $SRC_DIR/$P_V ) 
	${QT5DIR}/bin/qmake.exe $_rel_path/qtcreator.pro CONFIG+=release \
		> ${LOG_DIR}/${P_V}-configure.log 2>&1 || exit 1
	popd > /dev/null
}

pkg_build() {
	local _make_flags=(
		${MAKE_OPTS}
	)
	local _allmake="${_make_flags[@]}"
	func_make \
		build-${P_V} \
		"mingw32-make" \
		"$_allmake" \
		"building..." \
		"built"
}

pkg_install() {
	local _install_flags=(
		${MAKE_OPTS}
		INSTALL_ROOT=${QT5DIR}
		install
	)
	local _allinstall="${_install_flags[@]}"
	func_make \
		build-${P_V} \
		"/bin/make" \
		"$_allinstall" \
		"installing..." \
		"installed"

	for i in ${QT5DIR}/bin/*.a ; \
        do cp -f ${i} ${QT5DIR}/lib/; done
}
