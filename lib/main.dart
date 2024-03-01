import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nascon_app/firebase_options.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  (() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    runApp(const App());
  })();
}
