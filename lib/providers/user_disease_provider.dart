import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserDiseaseModel> _results = [];
  List<UserDiseaseModel> get results => _results;

  Future<void> findDiagnosis(List<String> userSymptoms) async {
    _isLoading = true;
    _results = [];
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _db.collection('diseases').get();

      // 1. Normalize user input: Lowercase, trim, and REMOVE HYPHENS
      List<String> cleanUserSymptoms = userSymptoms
          .map((s) => s.toLowerCase().replaceAll('-', ' ').trim())
          .toList();

      for (var doc in snapshot.docs) {
        // Target the 'symptoms' array as you requested
        List dbSymptoms = doc['symptoms'] ?? [];
        if (dbSymptoms.isEmpty) continue;

        // 2. Normalize DB symptoms: Lowercase, trim, and REMOVE HYPHENS
        List<String> normalizedDb = dbSymptoms
            .map((s) => s.toString().toLowerCase().replaceAll('-', ' ').trim())
            .toList();

        // 3. Check for 100% Match
        // Does the user's list contain EVERY symptom from the DB?
        bool isPerfectMatch = normalizedDb.every((dbS) =>
            cleanUserSymptoms.contains(dbS));

        // 4. Check for Symmetry (Exact same number of symptoms)
        bool sameLength = normalizedDb.length == cleanUserSymptoms.length;

        if (isPerfectMatch && sameLength) {
          _results.add(UserDiseaseModel.fromFirestore(doc));
        }
      }
    } catch (e) {
      debugPrint("Strict Diagnosis Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}