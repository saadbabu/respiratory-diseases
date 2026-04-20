import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../providers/disease_provider.dart';
import '../providers/phone_auth_provider.dart';
import '../providers/user_disease_provider.dart';

class AppProvider {
  static List<SingleChildWidget> providers = [
    // 1. Disease Data Provider
    ChangeNotifierProvider<DiseaseProvider>(
      create: (_) => DiseaseProvider(),
    ),

    // 2. User Specific Disease Logic Provider
    ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(),
    ),

    // 3. Authentication Provider (FIXED TYPE HERE)
    ChangeNotifierProvider<AuthSessionProvider>(
      create: (_) => AuthSessionProvider(),
    ),
  ];
}