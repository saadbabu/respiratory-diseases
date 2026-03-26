import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/disease_model.dart';

class DiseaseProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Add Disease
  Future<void> addDisease(Disease disease) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.collection('diseases').add(disease.toMap());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stream of systems for the Dropdown
  Stream<QuerySnapshot> getSystemsStream() {
    return _db.collection('system').snapshots();
  }
}