import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/disease_provider.dart';
// import 'auth_provider.dart'; // Example of another provider

class AppProvider {
  // This list will contain all the providers used in the application
  static List<SingleChildWidget> providers = [

    // Disease Management Provider
    ChangeNotifierProvider<DiseaseProvider>(
      create: (_) => DiseaseProvider(),
    ),

    /* Add more providers here as your app grows:
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(),
    ),
    */
  ];
}