import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5S8Inn4YJ1ClZE4f_AR2Rme3akz_YQBI',
    appId: '1:963087425185:android:47c0118eab410b36cadae0',
    messagingSenderId: '963087425185',
    projectId: 'myapp-97fe6',
    storageBucket: 'myapp-97fe6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAu8-ZYlqPL5ryxm4zpDsC1OZnc6QQSENk',
    appId: '1:1088741098589:ios:753fc50a45aff8bedeb9b4',
    messagingSenderId: '1088741098589',
    projectId: 'it302todolistapp-fe622',
    storageBucket: 'it302todolistapp-fe622.firebasestorage.app',
    iosBundleId: 'com.example.todoFirebaseApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCB4YF-5J_S1MQN5LsIoL6Wohr48bKBDwo',
    appId: '1:798040518897:web:844b8402e8c26c37cef950',
    messagingSenderId: '798040518897',
    projectId: 'it302todolistapp',
    authDomain: 'it302todolistapp.firebaseapp.com',
    storageBucket: 'it302todolistapp.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyByUSMbQht3RJFidvEHMNSC1EM6AMWI6iA',
    appId: '1:963087425185:web:46e3408f79b69013cadae0',
    messagingSenderId: '963087425185',
    projectId: 'myapp-97fe6',
    authDomain: 'myapp-97fe6.firebaseapp.com',
    storageBucket: 'myapp-97fe6.firebasestorage.app',
  );

}