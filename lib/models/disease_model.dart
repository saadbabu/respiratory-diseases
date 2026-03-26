import 'package:cloud_firestore/cloud_firestore.dart';

class Disease {
  final String name;
  final String organ;
  final DocumentReference system; // Store as a Reference
  final List<String> symptoms;
  final List<Map<String, dynamic>> medications;

  Disease({
    required this.name,
    required this.organ,
    required this.system,
    required this.symptoms,
    required this.medications,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'organ': organ,
      'system': system,
      'symptoms': symptoms,
      'symptoms_search': symptoms.map((s) => s.toLowerCase().trim()).toList(),
      'medications': medications,
    };
  }
}