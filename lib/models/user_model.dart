import 'package:cloud_firestore/cloud_firestore.dart';

class UserDiseaseModel {
  final String name;
  final String organ;
  final dynamic system;
  final List<String> symptoms;
  final List<Map<String, dynamic>> medications;

  UserDiseaseModel({
    required this.name,
    required this.organ,
    required this.system,
    required this.symptoms,
    required this.medications,
  });

  factory UserDiseaseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // --- FIXED MEDICATION LOGIC ---
    List<Map<String, dynamic>> processedMeds = [];
    var medsData = data['medications'];

    if (medsData is List) {
      // If it's already a list (standard behavior)
      processedMeds = medsData.map((m) => Map<String, dynamic>.from(m)).toList();
    } else if (medsData is Map) {
      // If it's a single Object (as seen in your screenshot)
      processedMeds = [Map<String, dynamic>.from(medsData)];
    }

    return UserDiseaseModel(
      name: data['name']?.toString() ?? 'Unknown Disease',
      organ: data['organ']?.toString() ?? 'Not Specified',
      system: data['system'],
      symptoms: List<String>.from(data['symptoms'] ?? []),
      medications: processedMeds.map((m) {
        return {
          'name': m['name']?.toString() ?? 'Unknown Med',
          // Safe price parsing
          'price': m['price'] is num ? m['price'] : int.tryParse(m['price'].toString()) ?? 0,
        };
      }).toList(),
    );
  }
}