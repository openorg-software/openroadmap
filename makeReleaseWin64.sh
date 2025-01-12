#!/bin/sh
flutter build windows -t lib/desktop/main.dart

VERSION=$(cat ./pubspec.yaml | grep version)
IFS=' '
read -raVERSION_ARRAY<<<"$VERSION"
VERSION_NUMBER=${VERSION_ARRAY[1]}
echo "$VERSION_NUMBER"
cd build/windows/x64/runner/Release && tar -czf "../../../../../openroadmap_${VERSION_NUMBER}_win64.tar.gz" *