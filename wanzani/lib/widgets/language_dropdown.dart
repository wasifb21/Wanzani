import 'package:flutter/material.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String selected = 'French';

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButton<String>(
          value: selected,
          items: ['French', 'English'].map((String lang) {
            return DropdownMenuItem<String>(value: lang, child: Text(lang));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selected = value;
              });
            }
          },
        ),
      ),
    );
  }
}
