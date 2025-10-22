// // locator.dart
// import 'package:agricultare_weather_pests/exports.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';

// final GetIt locator = GetIt.instance; // This is our phonebook

// Future<void> setupLocator() async {
//   // Register workers in the phonebook
//   locator.registerLazySingleton<AuthService>(() => AuthService());
//   locator.registerLazySingleton<PlantService>(() => PlantService());
// }

// // ! *******

// // auth_service.dart
// class AuthService {
//   // This worker handles login/logout
//   Future<void> login(String email, String password) async {
//     // API call code here
//   }
// }

// // plant_service.dart
// class PlantService {
//   // This worker handles plant-related API calls
//   Future<void> fetchPlants() async {
//     // API call code here
//   }
// }


// // ! ******
// // login_provider.dart
// class LoginProvider extends ChangeNotifier {
//   final AuthService authService; // This manager needs the auth worker
  
//   LoginProvider({required this.authService});
  
//   bool isLoading = false;
  
//   Future<void> login(String email, String password) async {
//     isLoading = true;
//     notifyListeners(); // Tell UI: "I'm busy!"
    
//     await authService.login(email, password); // Ask worker to do the job
    
//     isLoading = false;
//     notifyListenifiers(); // Tell UI: "I'm done!"
//   }
// }
// // ! ******
// // providers.dart
// List<SingleChildWidget> providerPath = [
//   // Manager + Worker connection
//   ChangeNotifierProvider(
//     create: (_) => LoginProvider(
//       authService: locator<AuthService>(), // Phonebook finds the auth worker
//     ),
//   ),
//   ChangeNotifierProvider(
//     create: (_) => PlantProvider(
//       plantService: locator<PlantService>(), // Phonebook finds plant worker
//     ),
//   ),
// ];
// // ! *****
// // main.dart
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   await setupLocator(); // Setup phonebook first
  
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: providerPath, // All our managers
//       child: MaterialApp(
//         home: HomeScreen(),
//       ),
//     );
//   }
// }

// // ! ******