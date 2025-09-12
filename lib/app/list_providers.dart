import 'package:provider/single_child_widget.dart';

import 'index.dart'; // Add this import

List<SingleChildWidget> providersLists = [
  Provider<NetworkInfo>(create: (context) => NetworkInfoImpl(Connectivity())),

  ChangeNotifierProvider(
    create: (context) => AuthProvider(authService: locator<AuthService>()),
  ),
  ChangeNotifierProvider(
    create: (context) => RegisterProvider(
      authService: locator<AuthService>(),
      imageUploadService: locator<ImageUploadService>(),
    ),
  ),
];
