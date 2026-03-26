import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/pdf_service.dart';
import '../../providers/user_disease_provider.dart';

class DiagnosisResultsScreen extends StatelessWidget {
  const DiagnosisResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = context.watch<UserProvider>().results;
    final isLoading = context.watch<UserProvider>().isLoading;

    // Design System Colors
    const Color accentBerry = Color(0xFFAD445A);
    const Color textCharcoal = Color(0xFF2D2727);
    const Color bgCanvas = Color(0xFFF9F5F6);

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        title: const Text("Medical Analysis",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: textCharcoal,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
              onPressed: results.isEmpty
                  ? null
                  : () async {
                // Show a simple loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preparing PDF Report..."), duration: Duration(seconds: 1))
                );

                // Generate and Share
                await PdfService.generateAndShareReport(results);
              },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentBerry))
          : results.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final disease = results[index];

          // Sort meds by price (lowest first)
          var meds = List.from(disease.medications);
          meds.sort((a, b) => a['price'].compareTo(b['price']));

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: textCharcoal.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // --- HEADER SECTION ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: accentBerry.withOpacity(0.06),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: accentBerry,
                        child: Icon(Icons.biotech, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(disease.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textCharcoal)),
                            Text("Target Organ: ${disease.organ}",
                                style: const TextStyle(color: accentBerry, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified_user, color: Colors.blueAccent, size: 20),
                    ],
                  ),
                ),

                // --- MEDICATION LIST SECTION ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("AVAILABLE PHARMACOLOGY",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                      const SizedBox(height: 15),
                      ...meds.map((m) {
                        bool isBestVal = meds.indexOf(m) == 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isBestVal ? Colors.green.withOpacity(0.06) : bgCanvas,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isBestVal ? Colors.green.withOpacity(0.3) : Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.medication_liquid, color: isBestVal ? Colors.green : Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: textCharcoal)),
                                    if (isBestVal)
                                      const Text("Most Affordable Option", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isBestVal ? Colors.green : textCharcoal,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text("Rs. ${m['price']}",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("No matches found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Try adjusting your symptoms.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}