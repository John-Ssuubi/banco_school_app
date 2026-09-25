 import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';
 
 Widget buildGalleryTab(isUploading, isLoadingImages, schoolImages, uploadSchoolImage, loadSchoolImages, deleteSchoolImage, openFullScreenImage, buildPlatformImage, buildEmptyState) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isUploading ? null : uploadSchoolImage,
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_photo_alternate),
            label: Text(isUploading ? 'Uploading...' : 'Upload School Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoadingImages
              ? const Center(child: CircularProgressIndicator())
              : schoolImages.isEmpty
              ? buildEmptyState(
                  'No Images',
                  'Upload school images to showcase your school',
                  Icons.photo_library,
                )
              : RefreshIndicator(
                  onRefresh: loadSchoolImages,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: schoolImages.length,
                    itemBuilder: (context, index) {
                      final imageUrl = schoolImages[index];

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            onTap: () => openFullScreenImage(imageUrl),
                            child: Hero(
                              tag: imageUrl,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: buildPlatformImage(imageUrl),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => deleteSchoolImage(imageUrl),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
