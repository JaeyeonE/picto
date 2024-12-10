import 'package:flutter/material.dart';
import 'package:picto/app.dart';
import 'package:picto/views/map/marker_image_processor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PhotoSharingApp());
}

// main 분리