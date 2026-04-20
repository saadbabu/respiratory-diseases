import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/disease_model.dart';
import '../../providers/disease_provider.dart';
import '../../providers/phone_auth_provider.dart';
import '../clinicaldisclaime.dart'; // IMPORT THIS

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

  // High-Contrast Professional Palette
  final Color bgCanvas = const Color(0xFFF9F5F6);
  final Color accentBerry = const Color(0xFFAD445A);
  final Color textCharcoal = const Color(0xFF2D2727);
  final Color borderMuted = const Color(0xFFD1B0B7);

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _organController.clear();
      _selectedSystemRef = null;
      _symptoms = [];
      _medications = [];
    });
  }

  // --- LOGOUT DIALOG ---
  void _showLogoutDialog(AuthSessionProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Admin Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to exit the Pharmacist Portal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Stay", style: TextStyle(color: textCharcoal)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut(); // This will trigger main.dart to show LoginScreen
            },
            child: Text("Logout", style: TextStyle(color: accentBerry, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiseaseProvider>();
    final authProvider = context.read<AuthSessionProvider>(); // READ AUTH PROVIDER

    return Scaffold(
      backgroundColor: bgCanvas,
      bottomNavigationBar: const ClinicalDisclaimer(),
      appBar: AppBar(
        title: Text("Pharmacist Admin Portal",
            style: TextStyle(color: textCharcoal, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        // ADDED LOGOUT BUTTON HERE
        leading: IconButton(
          icon: Icon(Icons.power_settings_new_rounded, color: accentBerry),
          onPressed: () => _showLogoutDialog(authProvider),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: accentBerry.withOpacity(0.3), height: 1),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            right: -50,
            child: Icon(Icons.biotech, size: 300, color: accentBerry.withOpacity(0.08)),
          ),

          provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFAD445A)))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildContainer(
                  title: "Classification",
                  icon: Icons.category,
                  child: Column(
                    children: [
                      _styledInput(_nameController, "Disease Name", Icons.edit),
                      _styledInput(_organController, "Affected Organ", Icons.accessibility_new),
                      _buildSystemDropdown(provider),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildContainer(
                  title: "Symptoms",
                  icon: Icons.list_alt,
                  child: _buildSymptomLogic(),
                ),
                const SizedBox(height: 20),
                _buildContainer(
                  title: "Pharmacology & Pricing",
                  icon: Icons.medication,
                  child: _buildMedicationLogic(),
                ),
                const SizedBox(height: 40),
                _buildSubmitButton(provider),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep all your existing _build methods below: _buildContainer, _styledInput, etc.)

  Widget _buildContainer({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderMuted, width: 1.5),
        boxShadow: [
          BoxShadow(color: textCharcoal.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentBerry, size: 24),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: textCharcoal, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const Divider(height: 25, thickness: 1),
          child,
        ],
      ),
    );
  }

  Widget _styledInput(TextEditingController ctrl, String label, IconData icon, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: textCharcoal, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: accentBerry),
          labelText: label,
          labelStyle: TextStyle(color: textCharcoal.withOpacity(0.6)),
          filled: true,
          fillColor: bgCanvas,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderMuted),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: accentBerry, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemDropdown(DiseaseProvider provider) {
    return StreamBuilder<QuerySnapshot>(
      stream: provider.getSystemsStream(),
      builder: (context, snapshot) {
        return DropdownButtonFormField<DocumentReference>(
          value: _selectedSystemRef,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.account_tree, color: accentBerry),
            labelText: "Select System",
            filled: true,
            fillColor: bgCanvas,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderMuted),
            ),
          ),
          items: snapshot.data?.docs.map((doc) => DropdownMenuItem(
            value: doc.reference,
            child: Text(doc['name'], style: TextStyle(color: textCharcoal)),
          )).toList() ?? [],
          onChanged: (val) => setState(() => _selectedSystemRef = val),
        );
      },
    );
  }

  Widget _buildSymptomLogic() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _styledInput(_symptomInputController, "Type Symptom", Icons.add_box)),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                if (_symptomInputController.text.isNotEmpty) {
                  setState(() => _symptoms.add(_symptomInputController.text.trim()));
                  _symptomInputController.clear();
                }
              },
              icon: Icon(Icons.add_circle, color: accentBerry, size: 40),
            )
          ],
        ),
        Wrap(
          spacing: 8,
          children: _symptoms.map((s) => Chip(
            backgroundColor: accentBerry,
            label: Text(s, style: const TextStyle(color: Colors.white)),
            deleteIconColor: Colors.white,
            onDeleted: () => setState(() => _symptoms.remove(s)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicationLogic() {
    return Column(
      children: [
        _styledInput(_medNameController, "Drug Name", Icons.vaccines),
        _styledInput(_medPriceController, "Price (Rs.)", Icons.paid, isNum: true),
        ElevatedButton.icon(
          onPressed: () {
            if (_medNameController.text.isNotEmpty) {
              setState(() => _medications.add({
                'name': _medNameController.text.trim(),
                'price': int.tryParse(_medPriceController.text.trim()) ?? 0,
              }));
              _medNameController.clear();
              _medPriceController.clear();
            }
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Medication", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: accentBerry),
        ),
        const SizedBox(height: 10),
        ..._medications.map((m) => ListTile(
          dense: true,
          title: Text(m['name'], style: TextStyle(color: textCharcoal, fontWeight: FontWeight.bold)),
          trailing: Text("Rs. ${m['price']}", style: TextStyle(color: accentBerry, fontWeight: FontWeight.w900)),
          onLongPress: () => setState(() => _medications.remove(m)),
        )),
      ],
    );
  }

  Widget _buildSubmitButton(DiseaseProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: textCharcoal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          if (_nameController.text.isEmpty || _selectedSystemRef == null) return;
          final disease = Disease(
            name: _nameController.text.trim(),
            organ: _organController.text.trim(),
            system: _selectedSystemRef!,
            symptoms: _symptoms,
            medications: _medications,
          );
          await provider.addDisease(disease);
          _clearForm();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Entry Added to Pharmacy DB")));
        },
        child: const Text("SAVE CLINICAL RECORD",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}