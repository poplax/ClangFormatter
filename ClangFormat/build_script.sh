#!/bin/sh

#  build_script.sh
#  ClangFormatter
#
#  Created by LinJiang on 24/01/2018.
#  Copyright © 2018 🚀. All rights reserved.

#set -e
TOOL_NAME=ClangFormat

XCODE_EXTENSION_NAME=ClangFormatter.app
PACKAGE_SHELL="package.sh"

APP_PACKAGE_DIR="${PROJECT_DIR}/Package/"
APP_PACKAGE_PATH="${BUILD_DIR}/${CONFIGURATION}/${XCODE_EXTENSION_NAME}"

CODE_STYLE_CONFIG_FILE_OBJC="_clang-format-objc"
CODE_STYLE_CONFIG_FILE="${PROJECT_DIR}/${TOOL_NAME}/style-config/${CODE_STYLE_CONFIG_FILE_OBJC}"

cp -fR "${CODE_STYLE_CONFIG_FILE}" "${APP_PACKAGE_DIR}"
cp -fR "${APP_PACKAGE_PATH}" "${APP_PACKAGE_DIR}"

pushd "${APP_PACKAGE_DIR}"
if [ -f "${PACKAGE_SHELL}" ]; then
    
    sh ${PACKAGE_SHELL}
fi

rm -fR ${CODE_STYLE_CONFIG_FILE_OBJC} ${XCODE_EXTENSION_NAME}
popd
