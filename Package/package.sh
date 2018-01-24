#!/bin/bash

GZ_FILE_NAME=lastest-version.gz 
UPDATE_CONFIG_BASH=update_config_file.sh
CONFIG_FILE=_clang-format-objc
APP_FILE_NAME=ClangFormatter.app


if [ ! -d "./$APP_FILE_NAME" ]; then
	echo "Error: '$APP_FILE_NAME' not exist."
	echo "Please build '$APP_FILE_NAME'."
	exit 0
fi

tar -czvf $GZ_FILE_NAME $APP_FILE_NAME $CONFIG_FILE $UPDATE_CONFIG_BASH README.md

