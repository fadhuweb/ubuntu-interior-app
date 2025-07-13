import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:ubuntu_app/utils/colors.dart';
// ignore: unused_import
import 'package:ubuntu_app/utils/text_styles.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final List<String> _languages = [
    'English (USA)',
    'French',
    'Kiswahili',
    'Afrikaans',
    'Kinyarwanda',
  ];
  String _selectedLanguage = 'English (USA)';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = _languages
        .where(
          (lang) => lang.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Languages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                fillColor: Colors.grey.shade300,
                filled: true,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Language list
            Expanded(
              child: ListView.builder(
                itemCount: filteredLanguages.length,
                itemBuilder: (context, index) {
                  String lang = filteredLanguages[index];
                  return ListTile(
                    title: Text(lang),
                    leading: Radio<String>(
                      value: lang,
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
