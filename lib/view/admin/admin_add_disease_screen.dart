import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/disease_model.dart';
import '../../providers/disease_provider.dart';

class AdminAddDiseaseScreen extends StatefulWidget {
  const AdminAddDiseaseScreen({super.key});

  @override
  State<AdminAddDiseaseScreen> createState() => _AdminAddDiseaseScreenState();
}

class _AdminAddDiseaseScreenState extends State<AdminAddDiseaseScreen> {
  final _nameController = TextEditingController();
  final _organController = TextEditingController();
  final _symptomInputController = TextEditingController();
  final _medNameController = TextEditingController();
  final _medPriceController = TextEditingController();

  DocumentReference? _selectedSystemRef;
  List<String> _symptoms = [];
  List<Map<String, dynamic>> _medications = [];

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _organController.clear();
      _selectedSystemRef = null;
      _symptoms = [];
      _medications = [];
    });
  }

  void _addSymptom() {
    if (_symptomInputController.text.isNotEmpty) {
      setState(() => _symptoms.add(_symptomInputController.text.trim()));
      _symptomInputController.clear();
    }
  }

  void _addMedication() {
    if (_medNameController.text.isNotEmpty && _medPriceController.text.isNotEmpty) {
      setState(() {
        _medications.add({
          'name': _medNameController.text.trim(),
          'price': int.tryParse(_medPriceController.text.trim()) ?? 0,
        });
      });
      _medNameController.clear();
      _medPriceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiseaseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Portal"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.withOpacity(0.1),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("General Info"),
            _customTextField(_nameController, "Disease Name"),
            _customTextField(_organController, "Organ"),

            // SYSTEM DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: provider.getSystemsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DropdownButtonFormField<DocumentReference>(
                    value: _selectedSystemRef,
                    hint: const Text("Select System"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<DocumentReference>(
                        value: doc.reference,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedSystemRef = val),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),
            _buildSectionTitle("Symptoms"),
            Row(
              children: [
                Expanded(child: _customTextField(_symptomInputController, "Add Symptom")),
                IconButton(onPressed: _addSymptom, icon: const Icon(Icons.add_circle, color: Colors.blue)),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _symptoms.map((s) => Chip(
                label: Text(s),
                onDeleted: () => setState(() => _symptoms.remove(s)),
              )).toList(),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle("Medications & Prices"),
            Row(
              children: [
                Expanded(flex: 2, child: _customTextField(_medNameController, "Med Name")),
                const SizedBox(width: 10),
                Expanded(child: _customTextField(_medPriceController, "Price", isNumber: true)),
                IconButton(onPressed: _addMedication, icon: const Icon(Icons.add_box, color: Colors.green)),
              ],
            ),
            ..._medications.asMap().entries.map((entry) => ListTile(
              title: Text(entry.value['name']),
              trailing: Text("Rs. ${entry.value['price']}"),
              leading: const Icon(Icons.medication),
              onLongPress: () => setState(() => _medications.removeAt(entry.key)),
            )),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_nameController.text.isEmpty || _symptoms.isEmpty || _selectedSystemRef == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all general info and add symptoms")),
                    );
                    return;
                  }

                  final disease = Disease(
                    name: _nameController.text.trim(),
                    organ: _organController.text.trim(),
                    system: _selectedSystemRef!,
                    symptoms: _symptoms,
                    medications: _medications,
                  );

                  try {
                    await provider.addDisease(disease);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Saved Successfully!"), backgroundColor: Colors.green),
                    );
                    _clearForm();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text("SAVE TO FIREBASE", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  Widget _customTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}