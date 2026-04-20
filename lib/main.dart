import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:respiratory_diseases/providers/phone_auth_provider.dart';
import 'package:respiratory_diseases/view/admin/admin_add_disease_screen.dart';
import 'package:respiratory_diseases/view/phone_signin_screen.dart';
import 'package:respiratory_diseases/view/user/symptom_entry_screen.dart';
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
        // home: const AdminAddDiseaseScreen(),
        home: Consumer<AuthSessionProvider>(
          builder: (context, auth, _) {
            // 1. If not logged in, show Login Screen
            if (!auth.isAuthenticated) {
              return const LoginScreen();
            }

            // 2. If logged in, check role
            if (auth.isAdmin) {
              return const AdminAddDiseaseScreen(); // Admin UI
            } else {
              return const SymptomCheckerDashboard(); // Standard User UI
            }
          },
        ),
        // home: const AdminAddDiseaseScreen(),
      ),
    );
  }
}