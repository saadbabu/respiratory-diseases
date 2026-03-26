import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:respiratory_diseases/view/admin/admin_add_disease_screen.dart';
import 'app/app_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider wraps the entire app with the list from AppProvider
    return MultiProvider(
      providers: AppProvider.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Respiratory Disease App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AdminAddDiseaseScreen(),
      ),
    );
  }
}