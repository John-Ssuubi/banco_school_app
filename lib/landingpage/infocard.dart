import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: mainColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE8ECF0)),
          child,
        ],
      ),
    );
  }


Widget buildInfoCard(Map<String, dynamic> data) {
    final address = data['address'] ?? 'N/A';
    final contact = data['contact'] ?? 'N/A';
    final email = data['email'] ?? 'N/A';
    final pobox = data['pobox'] ?? 'N/A';

    final infoItems = [
      {'label': 'Address', 'value': address, 'icon': Icons.location_on_rounded},
      {'label': 'Contact', 'value': contact, 'icon': Icons.phone_rounded},
      {'label': 'Email', 'value': email, 'icon': Icons.email_rounded},
      {'label': 'P.O. Box', 'value': pobox, 'icon': Icons.markunread_mailbox_rounded},
    ];

    return _buildSectionCard(
      title: "School Information",
      icon: Icons.info_outline_rounded,
      child: Column(
        children: infoItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, size: 18, color: mainColor),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    item['value'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A202C),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
