import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Import the new user-specific model

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Uses the new User-specific model
  List<UserDiseaseModel> _results = [];
  List<UserDiseaseModel> get results => _results;

  Future<void> findDiagnosis(List<String> userSymptoms) async {
    _isLoading = true;
    _results = [];
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _db.collection('diseases').get();

      // Normalize user input for better matching
      List<String> cleanUserSymptoms = userSymptoms
          .map((s) => s.toLowerCase().trim())
          .where((s) => s.isNotEmpty)
          .toList();

      for (var doc in snapshot.docs) {
        // Use the symptoms_search field created by the Admin side
        List dbSymptoms = doc['symptoms_search'] ?? [];

        // Flexible matching: checks if user input is inside DB symptoms or vice versa
        bool isMatch = cleanUserSymptoms.any((userSymptom) {
          return dbSymptoms.any((dbSymptom) =>
          dbSymptom.toString().contains(userSymptom) ||
              userSymptom.contains(dbSymptom.toString()));
        });

        if (isMatch) {
          // Add to results using the safe user-model factory
          _results.add(UserDiseaseModel.fromFirestore(doc));
        }
      }
    } catch (e) {
      debugPrint("Diagnosis Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}