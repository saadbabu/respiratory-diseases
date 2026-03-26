import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_disease_provider.dart';
import 'diagnosis_results_screen.dart';

class SymptomEntryScreen extends StatefulWidget {
  const SymptomEntryScreen({super.key});

  @override
  State<SymptomEntryScreen> createState() => _SymptomEntryScreenState();
}

class _SymptomEntryScreenState extends State<SymptomEntryScreen> {
  final List<String> _userSymptoms = [];
  final _inputController = TextEditingController();

  // Theme Colors
  final Color accentBerry = const Color(0xFFAD445A);
  final Color textCharcoal = const Color(0xFF2D2727);
  final Color bgCanvas = const Color(0xFFF9F5F6);

  @override
  Widget build(BuildContext context) {
    // We watch the provider to show a loading spinner if findDiagnosis is running
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        title: Text("Symptom Checker",
            style: TextStyle(color: textCharcoal, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // --- BACKGROUND WATERMARKS (IT/PHARMACY THEME) ---
          Positioned(
            bottom: -40,
            right: -40,
            child: Icon(Icons.biotech, size: 280, color: accentBerry.withOpacity(0.06)),
          ),
          Positioned(
            top: 20,
            left: -20,
            child: Icon(Icons.medication_outlined, size: 180, color: accentBerry.withOpacity(0.04)),
          ),

          // --- MAIN UI CONTENT ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Describe your condition",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textCharcoal),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add symptoms to find the most affordable treatments.",
                  style: TextStyle(color: textCharcoal.withOpacity(0.6), fontSize: 14),
                ),
                const SizedBox(height: 25),

                // SYMPTOM INPUT FIELD
                TextField(
                  controller: _inputController,
                  style: TextStyle(color: textCharcoal),
                  decoration: InputDecoration(
                    hintText: "e.g., Dry Cough, Fever",
                    prefixIcon: Icon(Icons.search, color: accentBerry),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle, color: accentBerry, size: 30),
                      onPressed: _addSymptom,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentBerry.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: accentBerry, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _addSymptom(),
                ),

                const SizedBox(height: 20),

                // SELECTED SYMPTOMS LIST
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _userSymptoms.map((symptom) => Chip(
                        label: Text(symptom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        backgroundColor: accentBerry,
                        deleteIcon: const Icon(Icons.cancel, color: Colors.white, size: 18),
                        onDeleted: () {
                          setState(() => _userSymptoms.remove(symptom));
                        },
                        elevation: 4,
                        shadowColor: accentBerry.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      )).toList(),
                    ),
                  ),
                ),

                // ACTION BUTTON
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textCharcoal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5,
                    ),
                    onPressed: (_userSymptoms.isEmpty || userProvider.isLoading)
                        ? null
                        : _handleDiagnosis,
                    child: userProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "ANALYZE & COMPARE COSTS",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // LOGIC: Add symptom with cleaning
  void _addSymptom() {
    String input = _inputController.text.trim();
    if (input.isNotEmpty) {
      setState(() {
        if (!_userSymptoms.contains(input)) {
          _userSymptoms.add(input);
        }
      });
      _inputController.clear();
    }
  }

  // LOGIC: Handle search and navigate
  void _handleDiagnosis() async {
    // Access provider without listening inside a function
    final provider = Provider.of<UserProvider>(context, listen: false);

    await provider.findDiagnosis(_userSymptoms);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DiagnosisResultsScreen()),
      );
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}