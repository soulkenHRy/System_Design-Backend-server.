#!/bin/bash
set -e

export FLUTTER_ROOT="/tmp/flutter"
export PUB_CACHE="/tmp/.pub-cache"

echo "=== Installing Flutter SDK ==="
if [ ! -d "$FLUTTER_ROOT" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"

echo "=== Flutter Version ==="
flutter --version

echo "=== Enabling Web ==="
flutter config --no-analytics
flutter config --enable-web

echo "=== Getting Dependencies ==="
flutter pub get

echo "=== Building Web ==="
flutter build web --release --base-href "/" --no-tree-shake-icons

echo "=== Build Complete ==="
ls -la build/web/
