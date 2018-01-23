#!/bin/bash

CLANG_FORMAT_OBJC="_clang-format-objc"
APP_CLANG_FORMAT_OBJC="/Applications/ClangFormatter.app/Contents/PlugIns/ClangFormat.appex/Contents/Resources/_clang-format-objc"

if [ ! -f "./_clang-format-objc" ]; then
	echo "\033[1;31m" "config file is not exsit."
	exit 0
fi

cp -f ./$CLANG_FORMAT_OBJC $APP_CLANG_FORMAT_OBJC

if [ $? -ne 0 ]; then
	echo "\033[1;31m" " Failed update."
	exit 0
fi

echo ""
echo "\033[1;32m" "Config file was updated, Success!" "\033[m"
echo ""

if [ -f "$APP_CLANG_FORMAT_OBJC" ]; then
	cat "$APP_CLANG_FORMAT_OBJC"
	echo ""
	echo "\033[1;32m" "Objc-config-style file content now is above. "
fi


