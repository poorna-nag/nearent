import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web is not supported.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCpYaZPIjR3LzCe0WKHkZ7IAWrnBsyFz_A',
    appId: '1:505817553520:android:5c67a056f9d6fc4becf2b5',
    messagingSenderId: '505817553520',
    projectId: 'nearent-d53dd',
    storageBucket: 'nearent-d53dd.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAY7BNNdXwEujJQ9liBcdRmIBTguu6jDvk',
    appId: '1:505817553520:ios:d2ca00c02e15678fecf2b5',
    messagingSenderId: '505817553520',
    projectId: 'nearent-d53dd',
    storageBucket: 'nearent-d53dd.firebasestorage.app',
    iosBundleId: 'Nearend',
  );
}
