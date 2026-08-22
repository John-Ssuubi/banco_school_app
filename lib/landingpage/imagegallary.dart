// imagegallary.dart
// ignore_for_file: avoid_print

import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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

// ============================================================
// SCHOOL IMAGE GALLERY
// ============================================================
//
// IMPORTANT:
//
// We DO NOT use Firebase Storage listAll().
//
// On Flutter Web, listAll() frequently throws:
// "[firebase_storage/channel-error] Unable to establish
// connection on channel: ...referenceListAll"
// because that pigeon channel isn't reliably wired up on web.
//
// Instead, gallery images are loaded from Firestore:
//
// Schools/{schoolId}/gallery/{documentId}
//
// Each document contains:
// - url
// - fileName
// - storagePath
// - createdAt
//
// This matches the same pattern used in about_school.dart.
class SchoolImageGallery extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const SchoolImageGallery({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<SchoolImageGallery> createState() => _SchoolImageGalleryState();
}

class _SchoolImageGalleryState extends State<SchoolImageGallery> {
  List<String> schoolImages = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchoolImages();
  }

  // ============================================================
  // LOAD IMAGES FROM FIRESTORE
  // ============================================================

  Future<void> _loadSchoolImages() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('gallery')
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Loading images took too long');
            },
          );

      final List<Map<String, dynamic>> images = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final url = data['url'];

        if (url is String && url.trim().isNotEmpty) {
          images.add({
            'url': url.trim(),
            'createdAt': data['createdAt'],
          });
        }
      }

      // Sort locally instead of using Firestore orderBy().
      //
      // This avoids problems if some old gallery documents
      // don't contain createdAt.
      images.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];

        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        if (aTime is Timestamp) return -1;
        if (bTime is Timestamp) return 1;
        return 0;
      });

      final imageUrls =
          images.map<String>((image) => image['url'] as String).toList();

      if (!mounted) return;

      setState(() {
        schoolImages = imageUrls;
        isLoading = false;
        if (imageUrls.isEmpty) {
          errorMessage = 'No images found in gallery';
        }
      });
    } on TimeoutException {
      print('Timeout loading images');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Request timed out. Please try again.';
        });
      }
    } catch (e) {
      print('Error loading images: $e');
      String userMessage = 'Failed to load images';

      if (e.toString().contains('permission')) {
        userMessage = 'Permission denied. Please check Firestore rules.';
      } else if (e.toString().contains('not found') ||
          e.toString().contains('does not exist')) {
        userMessage = 'No gallery found for this school.';
      } else if (e.toString().contains('channel-error')) {
        userMessage = 'Connection error. Please check your internet connection.';
      }

      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = userMessage;
        });
      }
    }
  }

  Future<void> _retryLoading() async {
    await _loadSchoolImages();
  }

  // ============================================================
  // FULL-SCREEN IMAGE VIEWER
  // ============================================================

  void _openFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenImageViewer(imageUrl: imageUrl),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: "School Gallery",
      icon: Icons.photo_library_rounded,
      child: SizedBox(
        height: 120,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading images...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && schoolImages.isEmpty) {
      final isEmptyState = errorMessage == 'No images found in gallery';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEmptyState
                  ? Icons.photo_library_outlined
                  : Icons.error_outline_rounded,
              size: isEmptyState ? 40 : 30,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isEmptyState) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _retryLoading,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mainColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: schoolImages.length > 5 ? 5 : schoolImages.length,
      itemBuilder: (context, index) {
        final imageUrl = schoolImages[index];

        return Padding(
          padding: EdgeInsets.only(
            right: index < schoolImages.length - 1 ? 8 : 0,
          ),
          child: GestureDetector(
            onTap: () => _openFullScreenImage(imageUrl),
            child: Hero(
              tag: imageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 160,
                  height: 120,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 160,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: mainColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 160,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Image ${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// FULL-SCREEN IMAGE VIEWER WIDGET
// ============================================================

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Pinch-to-zoom, pan, full image.
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Hero(
                  tag: imageUrl,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: double.infinity,
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Close button.
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MAIN ENTRY FUNCTION
// ============================================================

Widget buildSchoolImageGallery(Map<String, dynamic> data, schoolId) {
  final schoolName = data['school_name'] ?? data['schoolName'] ?? 'School';

  // If we have a school ID, load images from Firestore.
  if (schoolId.isNotEmpty) {
    return SchoolImageGallery(
      schoolId: schoolId,
      schoolName: schoolName,
    );
  }

  // Fallback: return empty state if no school ID.
  return _buildSectionCard(
    title: "School Gallery",
    icon: Icons.photo_library_rounded,
    child: SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              'School ID not available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}