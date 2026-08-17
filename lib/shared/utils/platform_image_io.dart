import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider imageProviderFromPath(String path) => FileImage(File(path));
