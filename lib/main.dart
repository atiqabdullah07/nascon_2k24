import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nascon_app/firebase_options.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  (() async {
    ///
    /// Firebase App Initialization
    ///
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    ///
    /// Firebase Database Configurations

    /// Offline Access / Disk Persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    ///
    /// Main Activity
    ///
    runApp(const App());
  })();
}
