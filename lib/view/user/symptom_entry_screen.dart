import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/pdf_service.dart';
import '../../providers/phone_auth_provider.dart';
import '../../providers/user_disease_provider.dart';
import '../clinicaldisclaime.dart';

class SymptomCheckerDashboard extends StatefulWidget {
  const SymptomCheckerDashboard({super.key});

  @override
  State<SymptomCheckerDashboard> createState() => _SymptomCheckerDashboardState();
}

class _SymptomCheckerDashboardState extends State<SymptomCheckerDashboard> {
  final List<String> _userSymptoms = [];
  final _inputController = TextEditingController();

  // Theme Colors
  final Color accentBerry = const Color(0xFFAD445A);
  final Color textCharcoal = const Color(0xFF2D2727);
  final Color bgCanvas = const Color(0xFFF9F5F6);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.read<AuthSessionProvider>(); // Access auth logic
    final results = userProvider.results;

    return Scaffold(
      backgroundColor: bgCanvas,
      bottomNavigationBar: const ClinicalDisclaimer(),
      appBar: AppBar(
        title: Text("Symptom Checker",
            style: TextStyle(color: textCharcoal, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.logout_rounded, color: accentBerry), // Logout button
          onPressed: () => _showLogoutDialog(authProvider),
        ),
        actions: [
          if (results.isNotEmpty)
            IconButton(
              icon: Icon(Icons.ios_share, color: textCharcoal),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preparing PDF Report..."), duration: Duration(seconds: 1))
                );
                await PdfService.generateAndShareReport(results);
              },
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: textCharcoal),
            onPressed: _resetAll,
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Watermark
          Positioned(
            bottom: -40,
            right: -40,
            child: Icon(Icons.biotech, size: 280, color: accentBerry.withOpacity(0.06)),
          ),

          CustomScrollView(
            slivers: [
              // --- SECTION 1: INPUT ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Describe your condition",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textCharcoal)),
                      const SizedBox(height: 8),
                      Text("Add symptoms to find the most affordable treatments.",
                          style: TextStyle(color: textCharcoal.withOpacity(0.6), fontSize: 14)),
                      const SizedBox(height: 25),

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
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _addSymptom(),
                      ),

                      const SizedBox(height: 15),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _userSymptoms.map((symptom) => Chip(
                          label: Text(symptom, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          backgroundColor: accentBerry,
                          deleteIcon: const Icon(Icons.cancel, color: Colors.white, size: 14),
                          onDeleted: () => setState(() => _userSymptoms.remove(symptom)),
                        )).toList(),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textCharcoal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: (_userSymptoms.isEmpty || userProvider.isLoading) ? null : _handleSearch,
                          child: userProvider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("ANALYZE & COMPARE COSTS",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Divider(indent: 24, endIndent: 24)),

              // --- SECTION 2: RESULTS ---
              if (userProvider.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (results.isEmpty && _userSymptoms.isNotEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final disease = results[index];
                        var meds = List.from(disease.medications);
                        meds.sort((a, b) => a['price'].compareTo(b['price']));

                        return _buildDiseaseReportCard(disease, meds);
                      },
                      childCount: results.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LOGOUT DIALOG ---
  void _showLogoutDialog(AuthSessionProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to exit the diagnostic portal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: textCharcoal)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.signOut(); // Triggers session end
            },
            child: Text("Logout", style: TextStyle(color: accentBerry, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ... (Rest of your UI Components: _buildDiseaseReportCard, _buildEmptyState, etc. remain the same)

  Widget _buildDiseaseReportCard(disease, meds) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(disease.name.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.w900, color: textCharcoal, fontSize: 13, letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text("System: Respiratory", style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: accentBerry.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(disease.organ.toUpperCase(), style: TextStyle(color: accentBerry, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: bgCanvas.withOpacity(0.5),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text("PHARMACOLOGICAL AGENT", style: _tableLabelStyle())),
                Expanded(flex: 2, child: Text("EST. PRICE", textAlign: TextAlign.right, style: _tableLabelStyle())),
                const SizedBox(width: 35),
              ],
            ),
          ),
          ...meds.map((m) {
            bool isBest = meds.indexOf(m) == 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isBest ? Colors.green.withOpacity(0.02) : Colors.transparent,
                border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['name'], style: TextStyle(fontWeight: isBest ? FontWeight.bold : FontWeight.w500, fontSize: 14, color: textCharcoal)),
                        if (isBest)
                          const Text("Best Value Choice", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Rs. ${m['price']}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: isBest ? Colors.green.shade700 : textCharcoal
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 35,
                    child: Icon(
                      isBest ? Icons.verified_rounded : Icons.info_outline_rounded,
                      size: 18,
                      color: isBest ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  TextStyle _tableLabelStyle() {
    return TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade300, letterSpacing: 0.5);
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("No diagnostic matches found.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _addSymptom() {
    String input = _inputController.text.trim();
    if (input.isNotEmpty) {
      setState(() {
        if (!_userSymptoms.contains(input)) _userSymptoms.add(input);
      });
      _inputController.clear();
    }
  }

  void _handleSearch() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    await provider.findDiagnosis(_userSymptoms);
  }

  void _resetAll() {
    setState(() {
      _userSymptoms.clear();
      _inputController.clear();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}