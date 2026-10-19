import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

Widget buildHeaderCard(
  String schoolName,
  String moto,
  String subscription, {
  String? logoUrl,
  VoidCallback? onAddLogo,
  bool isUploadingLogo = false,
}) {
  final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        // ignore: deprecated_member_use
        colors: [mainColor, mainColor.withOpacity(0.8)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: mainColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        // Logo / add-logo avatar
        GestureDetector(
          onTap: hasLogo ? null : onAddLogo,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: isUploadingLogo
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : hasLogo
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schoolName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                moto,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: subscription == 'Paid' ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            subscription,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}