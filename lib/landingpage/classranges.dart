// ignore_for_file: deprecated_member_use

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

  Widget buildClassRangesCard(Map<String, dynamic> data,) {
    final classRanges = [
      {'label': 'D1', 'start': data['D1Start'] ?? 0, 'end': data['D1End'] ?? 0},
      {'label': 'D2', 'start': data['D2Start'] ?? 0, 'end': data['D2End'] ?? 0},
      {'label': 'C3', 'start': data['c3Start'] ?? 0, 'end': data['c3End'] ?? 0},
      {'label': 'C4', 'start': data['c4Start'] ?? 0, 'end': data['c4End'] ?? 0},
      {'label': 'C5', 'start': data['c5Start'] ?? 0, 'end': data['c5End'] ?? 0},
      {'label': 'C6', 'start': data['c6Start'] ?? 0, 'end': data['c6End'] ?? 0},
      {'label': 'P7', 'start': data['p7Start'] ?? 0, 'end': data['p7End'] ?? 0},
      {'label': 'P8', 'start': data['p8Start'] ?? 0, 'end': data['p8End'] ?? 0},
      {'label': 'F9', 'start': data['f9Start'] ?? 0, 'end': data['f9End'] ?? 0},
    ];

    // Filter out classes with both start and end as 0
    final activeRanges = classRanges.where((range) => 
      (range['start'] as int) > 0 || (range['end'] as int) > 0
    ).toList();

    if (activeRanges.isEmpty) {
      return _buildSectionCard(
        title: "Class Ranges",
        icon: Icons.groups_rounded,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'No class ranges configured',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ),
        ),
      );
    }

    return _buildSectionCard(
      title: "Class Ranges",
      icon: Icons.groups_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: activeRanges.map((range) {
          final label = range['label'] as String;
          final start = range['start'] as int;
          final end = range['end'] as int;
          
          final colorIndex = activeRanges.indexOf(range) % 5;
          final colors = [
            const Color(0xFF4CAF50),
            const Color(0xFF2196F3),
            const Color(0xFF9C27B0),
            const Color(0xFFFF9800),
            const Color(0xFFE91E63),
          ];
          final color = colors[colorIndex];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$label: $start - $end',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }