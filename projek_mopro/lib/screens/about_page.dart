import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.store_mall_directory_rounded,
                  size: 80,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "CampusStore Pro",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Versi 1.0.0",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              _buildContributorSection(),
              const Spacer(),
              const Text(
                "© 2025 CampusStore Team",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContributorSection() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Tim Pengembang",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildContributorItem("Shatahaq", "Lead Developer"),
                  const Divider(height: 24),
                  _buildContributorItem("Febiola Arn", "Developer"),
                  const Divider(height: 24),
                  _buildContributorItem("Alif", "Developer"),
                  const Divider(height: 24),
                  _buildContributorItem("Nadya", "Developer"),
                  const Divider(height: 24),
                  _buildContributorItem("Elaine", "Developer"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorItem(String name, String role) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Text(
            name[0],
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              role,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
