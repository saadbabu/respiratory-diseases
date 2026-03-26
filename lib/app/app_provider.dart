import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/disease_provider.dart';
import '../providers/user_disease_provider.dart';

class AppProvider {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider<DiseaseProvider>(create: (_) => DiseaseProvider()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()), // Class name must match exactly
  ];
}