import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider imageProviderFromPath(String path) {
  if (path.startsWith('http://') ||
      path.startsWith('https://') ||
      path.startsWith('blob:')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}
