import 'package:flutter/material.dart';
import 'package:wood_service/app/list_providers.dart';

import 'app/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();

  runApp(MultiProvider(providers: providersLists, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
