// // lib/widgets/photo_upload_widget.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:path/path.dart' as path;

// class PhotoUploadWidget extends StatefulWidget {
//   final List<String> uploadedPhotos; // Now expects URLs, not local paths
//   final Function(List<String>) onPhotosUploaded;
//   final int maxPhotos;
//   final String deviceId; // Add deviceId for unique storage paths

//   const PhotoUploadWidget({
//     Key? key,
//     required this.uploadedPhotos,
//     required this.onPhotosUploaded,
//     required this.deviceId, // Required for Firebase Storage path
//     this.maxPhotos = 5,
//   }) : super(key: key);

//   @override
//   State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
// }

// class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
//   final Set<String> _uploadingPhotos = {}; // Track photos being uploaded
  
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Device Photos',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87
//               ),
//             ),
//             Text(
//               '${widget.uploadedPhotos.length}/${widget.maxPhotos}',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
        
//         // Photo grid preview
//         if (widget.uploadedPhotos.isNotEmpty || _uploadingPhotos.isNotEmpty) ...[
//           Container(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: widget.uploadedPhotos.length + _uploadingPhotos.length,
//               itemBuilder: (context, index) {
//                 // Show uploading photos first, then uploaded photos
//                 if (index < _uploadingPhotos.length) {
//                   // Show uploading photo with progress indicator
//                   return _buildUploadingPhoto();
//                 } else {
//                   // Show uploaded photo
//                   final photoIndex = index - _uploadingPhotos.length;
//                   return _buildPhotoPreview(photoIndex);
//                 }
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
        
//         // Upload button
//         Container(
//           height: 100,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
//                   ? Colors.grey.shade300 
//                   : Colors.blue.shade300,
//               style: BorderStyle.solid,
//             ),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
//                   ? null 
//                   : () => _showPhotoOptions(context),
//               borderRadius: BorderRadius.circular(8),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
//                         ? Icons.check_circle_outline
//                         : Icons.add_photo_alternate_outlined,
//                     size: 32,
//                     color: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
//                         ? Colors.green.shade400
//                         : Colors.blue.shade400,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
//                         ? 'Maximum photos reached'
//                         : _uploadingPhotos.isNotEmpty ? 'Uploading...' : 'Add Photos',
//                     style: TextStyle(
//                       color: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
//                           ? Colors.grey.shade600
//                           : Colors.blue.shade600,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   if ((widget.uploadedPhotos.length + _uploadingPhotos.length) < widget.maxPhotos && _uploadingPhotos.isEmpty)
//                     Text(
//                       'Tap to upload from camera or gallery',
//                       style: TextStyle(
//                         color: Colors.grey.shade500,
//                         fontSize: 11,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUploadingPhoto() {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: Container(
//         width: 100,
//         height: 100,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.blue.shade300),
//           color: Colors.blue.shade50,
//         ),
//         child: const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Uploading...',
//               style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.blue,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPhotoPreview(int index) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: Stack(
//         children: [
//           // Photo preview - Now using network image since we have URLs
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 widget.uploadedPhotos[index], // Now this is a URL!
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(
//                     color: Colors.grey.shade200,
//                     child: const Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     color: Colors.grey.shade200,
//                     child: Icon(
//                       Icons.broken_image,
//                       color: Colors.grey.shade400,
//                       size: 32,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           // Delete button
//           Positioned(
//             top: 4,
//             right: 4,
//             child: GestureDetector(
//               onTap: () => _removePhoto(index),
//               child: Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//           // View full screen button
//           Positioned(
//             bottom: 4,
//             right: 4,
//             child: GestureDetector(
//               onTap: () => _viewFullScreen(context, index),
//               child: Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.fullscreen,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _removePhoto(int index) async {
//     try {
//       // Delete from Firebase Storage
//       await _deleteFromFirebaseStorage(widget.uploadedPhotos[index]);
      
//       // Remove from local list
//       List<String> newPhotos = List.from(widget.uploadedPhotos);
//       newPhotos.removeAt(index);
//       widget.onPhotosUploaded(newPhotos);
//     } catch (e) {
//       print('Error deleting photo: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error deleting photo: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _deleteFromFirebaseStorage(String imageUrl) async {
//     try {
//       // Extract the file path from the URL to delete it
//       final ref = FirebaseStorage.instance.refFromURL(imageUrl);
//       await ref.delete();
//     } catch (e) {
//       print('Error deleting from Firebase Storage: $e');
//       rethrow;
//     }
//   }

//   void _viewFullScreen(BuildContext context, int initialIndex) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PhotoViewerScreen(
//           photos: widget.uploadedPhotos, // These are now URLs
//           initialIndex: initialIndex,
//           onDelete: (index) {
//             Navigator.pop(context);
//             _removePhoto(index);
//           },
//         ),
//       ),
//     );
//   }

//   void _showPhotoOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Select Photo Source',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: _PhotoSourceButton(
//                     icon: Icons.camera_alt,
//                     label: 'Camera',
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImage(ImageSource.camera);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _PhotoSourceButton(
//                     icon: Icons.photo_library,
//                     label: 'Gallery',
//                     onTap: () {
//                       Navigator.pop(context);
//                       _pickImage(ImageSource.gallery);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // MAIN FIX: Upload to Firebase Storage and get URL
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? image = await picker.pickImage(
//         source: source,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
      
//       if (image != null) {
//         // Add to uploading set to show progress
//         final tempId = DateTime.now().millisecondsSinceEpoch.toString();
//         setState(() {
//           _uploadingPhotos.add(tempId);
//         });

//         try {
//           // Upload to Firebase Storage and get URL
//           final downloadUrl = await _uploadToFirebaseStorage(File(image.path));
          
//           // Remove from uploading set
//           setState(() {
//             _uploadingPhotos.remove(tempId);
//           });
          
//           // Add URL to photos list
//           List<String> newPhotos = List.from(widget.uploadedPhotos);
//           newPhotos.add(downloadUrl);
//           widget.onPhotosUploaded(newPhotos);
          
//         } catch (e) {
//           // Remove from uploading set on error
//           setState(() {
//             _uploadingPhotos.remove(tempId);
//           });
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Upload failed: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error selecting image: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // NEW: Upload file to Firebase Storage and return download URL
//   Future<String> _uploadToFirebaseStorage(File imageFile) async {
//     try {
//       // Create unique filename
//       final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      
//       // Create reference to Firebase Storage
//       final Reference storageRef = FirebaseStorage.instance
//           .ref()
//           .child('device_photos')
//           .child(widget.deviceId)
//           .child(fileName);
      
//       // Upload file
//       final UploadTask uploadTask = storageRef.putFile(imageFile);
      
//       // Wait for upload to complete
//       final TaskSnapshot taskSnapshot = await uploadTask;
      
//       // Get download URL
//       final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
//       return downloadUrl;
//     } catch (e) {
//       print('Error uploading to Firebase Storage: $e');
//       throw Exception('Failed to upload image: $e');
//     }
//   }
// }

// class _PhotoSourceButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _PhotoSourceButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 20),
//             child: Column(
//               children: [
//                 Icon(
//                   icon,
//                   size: 32,
//                   color: Colors.blue.shade600,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PhotoViewerScreen extends StatefulWidget {
//   final List<String> photos; // Now expects URLs
//   final int initialIndex;
//   final Function(int) onDelete;

//   const PhotoViewerScreen({
//     Key? key,
//     required this.photos,
//     required this.initialIndex,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
// }

// class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
//   late PageController _pageController;
//   late int _currentIndex;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         title: Text('${_currentIndex + 1} of ${widget.photos.length}'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () => _showDeleteConfirmation(),
//           ),
//         ],
//       ),
//       body: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.photos.length,
//         onPageChanged: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         itemBuilder: (context, index) {
//           return InteractiveViewer(
//             child: Center(
//               child: Image.network(
//                 widget.photos[index], // Now using network image!
//                 fit: BoxFit.contain,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.broken_image,
//                           color: Colors.white54,
//                           size: 64,
//                         ),
//                         SizedBox(height: 16),
//                         Text(
//                           'Unable to load image',
//                           style: TextStyle(color: Colors.white54),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _showDeleteConfirmation() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Photo'),
//         content: const Text('Are you sure you want to delete this photo?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               widget.onDelete(_currentIndex);
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/widgets/photo_upload_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class PhotoUploadWidget extends StatefulWidget {
  final List<String> uploadedPhotos; // Now expects URLs, not local paths
  final Function(List<String>) onPhotosUploaded;
  final int maxPhotos;
  final String deviceId; // Add deviceId for unique storage paths

  const PhotoUploadWidget({
    Key? key,
    required this.uploadedPhotos,
    required this.onPhotosUploaded,
    required this.deviceId, // Required for Firebase Storage path
    this.maxPhotos = 5,
  }) : super(key: key);

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  final Set<String> _uploadingPhotos = {}; // Track photos being uploaded
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Device Photos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87
              ),
            ),
            Text(
              '${widget.uploadedPhotos.length}/${widget.maxPhotos}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Photo grid preview
        if (widget.uploadedPhotos.isNotEmpty || _uploadingPhotos.isNotEmpty) ...[
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.uploadedPhotos.length + _uploadingPhotos.length,
              itemBuilder: (context, index) {
                // Show uploading photos first, then uploaded photos
                if (index < _uploadingPhotos.length) {
                  // Show uploading photo with progress indicator
                  return _buildUploadingPhoto();
                } else {
                  // Show uploaded photo
                  final photoIndex = index - _uploadingPhotos.length;
                  return _buildPhotoPreview(photoIndex);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Upload button
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
                  ? Colors.grey.shade300 
                  : Colors.blue.shade300,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
                  ? null 
                  : () => _showPhotoOptions(context),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
                        ? Icons.check_circle_outline
                        : Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
                        ? Colors.green.shade400
                        : Colors.blue.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
                        ? 'Maximum photos reached'
                        : _uploadingPhotos.isNotEmpty ? 'Uploading...' : 'Add Photos',
                    style: TextStyle(
                      color: (widget.uploadedPhotos.length + _uploadingPhotos.length) >= widget.maxPhotos 
                          ? Colors.grey.shade600
                          : Colors.blue.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if ((widget.uploadedPhotos.length + _uploadingPhotos.length) < widget.maxPhotos && _uploadingPhotos.isEmpty)
                    Text(
                      'Tap to upload from camera or gallery',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingPhoto() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300),
          color: Colors.blue.shade50,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 8),
            Text(
              'Uploading...',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Photo preview - Now using network image since we have URLs
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.uploadedPhotos[index], // Now this is a URL!
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey.shade400,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _showDeleteConfirmation(context, index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          // View full screen button
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _viewFullScreen(context, index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add confirmation dialog for delete
  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Photo'),
          content: const Text('Are you sure you want to delete this photo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removePhoto(index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _removePhoto(int index) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Delete from Firebase Storage
      await _deleteFromFirebaseStorage(widget.uploadedPhotos[index]);
      
      // Remove from local list
      List<String> newPhotos = List.from(widget.uploadedPhotos);
      newPhotos.removeAt(index);
      widget.onPhotosUploaded(newPhotos);

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print('Error deleting photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFromFirebaseStorage(String imageUrl) async {
    try {
      print('Attempting to delete image from URL: $imageUrl');
      
      // Check if the URL is a valid Firebase Storage URL
      if (!imageUrl.contains('firebasestorage.googleapis.com')) {
        throw Exception('Invalid Firebase Storage URL');
      }

      // Extract the file path from the URL to delete it
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      print('Firebase Storage reference path: ${ref.fullPath}');
      
      await ref.delete();
      print('Successfully deleted from Firebase Storage');
    } catch (e) {
      print('Error deleting from Firebase Storage: $e');
      
      // Try alternative deletion method if the first one fails
      try {
        await _alternativeDeleteMethod(imageUrl);
      } catch (altError) {
        print('Alternative delete method also failed: $altError');
        throw Exception('Failed to delete image: $e');
      }
    }
  }

  // Alternative delete method for edge cases
  Future<void> _alternativeDeleteMethod(String imageUrl) async {
    try {
      // Parse the URL to extract the path manually
      Uri uri = Uri.parse(imageUrl);
      String path = uri.pathSegments.last;
      
      // Remove URL encoding and get the actual file path
      path = Uri.decodeComponent(path);
      
      // If the path contains query parameters, remove them
      if (path.contains('?')) {
        path = path.split('?').first;
      }
      
      print('Attempting alternative delete with path: $path');
      
      // Try to construct the reference manually
      final ref = FirebaseStorage.instance
          .ref()
          .child('device_photos')
          .child(widget.deviceId)
          .child(path);
      
      await ref.delete();
      print('Alternative delete method succeeded');
    } catch (e) {
      print('Alternative delete method failed: $e');
      rethrow;
    }
  }

  void _viewFullScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photos: widget.uploadedPhotos, // These are now URLs
          initialIndex: initialIndex,
          onDelete: (index) {
            Navigator.pop(context);
            _removePhoto(index);
          },
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Photo Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PhotoSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PhotoSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // MAIN FIX: Upload to Firebase Storage and get URL
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Add to uploading set to show progress
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        setState(() {
          _uploadingPhotos.add(tempId);
        });

        try {
          // Upload to Firebase Storage and get URL
          final downloadUrl = await _uploadToFirebaseStorage(File(image.path));
          
          // Remove from uploading set
          setState(() {
            _uploadingPhotos.remove(tempId);
          });
          
          // Add URL to photos list
          List<String> newPhotos = List.from(widget.uploadedPhotos);
          newPhotos.add(downloadUrl);
          widget.onPhotosUploaded(newPhotos);
          
        } catch (e) {
          // Remove from uploading set on error
          setState(() {
            _uploadingPhotos.remove(tempId);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Upload file to Firebase Storage and return download URL
  Future<String> _uploadToFirebaseStorage(File imageFile) async {
    try {
      // Create unique filename
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      
      // Create reference to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('device_photos')
          .child(widget.deviceId)
          .child(fileName);
      
      // Upload file
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      
      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading to Firebase Storage: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}

class _PhotoSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoViewerScreen extends StatefulWidget {
  final List<String> photos; // Now expects URLs
  final int initialIndex;
  final Function(int) onDelete;

  const PhotoViewerScreen({
    Key? key,
    required this.photos,
    required this.initialIndex,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} of ${widget.photos.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.photos[index], // Now using network image!
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Unable to load image',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(_currentIndex);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}