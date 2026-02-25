#!/bin/bash
set -e

echo "=== Installing Flutter SDK ==="
FLUTTER_VERSION="3.27.4"
git clone --depth 1 --branch ${FLUTTER_VERSION}-stable https://github.com/flutter/flutter.git /tmp/flutter 2>/dev/null || \
git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /tmp/flutter

export PATH="/tmp/flutter/bin:/tmp/flutter/bin/cache/dart-sdk/bin:$PATH"

echo "=== Flutter Version ==="
flutter --version

echo "=== Enabling Web ==="
flutter config --enable-web

echo "=== Getting Dependencies ==="
flutter pub get

echo "=== Building Web ==="
flutter build web --release --base-href "/" --web-renderer html

echo "=== Build Complete ==="
ls -la build/web/
