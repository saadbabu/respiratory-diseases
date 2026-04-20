import 'package:flutter/material.dart';

class ClinicalDisclaimer extends StatelessWidget {
  const ClinicalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFAD445A).withOpacity(0.05), // Light Berry tint
        border: const Border(
          top: BorderSide(color: Color(0xFFD1B0B7), width: 0.5),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFFAD445A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "IMPORTANT: This tool is for informational purposes only. Please consult a certified medical professional before starting any treatment.",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2727),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}