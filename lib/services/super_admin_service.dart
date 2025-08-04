import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class SuperAdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify super admin credentials
  static Future<bool> verifySuperAdminCredentials(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      print('Hashed password: $hashedPassword');
      
      final querySnapshot = await _firestore
          .collection('super_admin')
          .where('username', isEqualTo: username)
          .where('hashedPassword', isEqualTo: hashedPassword)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error verifying super admin credentials: $e');
      return false;
    }
  }

  /// Get super admin data
  static Future<Map<String, dynamic>?> getSuperAdminData(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('super_admin')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error getting super admin data: $e');
      return null;
    }
  }

  /// Get all admins
  static Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection('admins')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting all admins: $e');
      return [];
    }
  }

  /// Remove admin
  static Future<bool> removeAdmin(String adminId) async {
    try {
      // Get admin document first to check isPromotedTechnician status
      final adminDoc = await _firestore.collection('admins').doc(adminId).get();
      
      if (!adminDoc.exists) {
        print('Admin document not found');
        return false;
      }

      final adminData = adminDoc.data() as Map<String, dynamic>;
      final promotedFromTechnician = adminData['promotedFromTechnician'] ?? false;

      if (promotedFromTechnician == true) {
        // This admin was not promoted from technician, so we need to find them in technicians collection
        // and change their role back to 'tech'
        
        // First, try to find the technician by UID
        final technicianDoc = await _firestore.collection('technicians').doc(adminId).get();
        
        if (technicianDoc.exists) {
          // Update technician role back to 'tech'
          await _firestore.collection('technicians').doc(adminId).update({
            'role': 'tech',
            'hasAdminAccess': false,
            'adminAccessStatus': 'removed',
            'adminAccessRemovedAt': FieldValue.serverTimestamp(),
            'isPromotedToAdmin': false,
          });
        } 
      } 

      // Remove from admin collection
      await _firestore.collection('admins').doc(adminId).delete();

      return true;
    } catch (e) {
      print('Error removing admin: $e');
      return false;
    }
  }

  /// Get super key
  static Future<String?> getSuperKey() async {
    try {
      final doc = await _firestore
          .collection('super_admin')
          .doc('config')
          .get();

      if (doc.exists) {
        return doc.data()?['superKey'];
      }
      return null;
    } catch (e) {
      print('Error getting super key: $e');
      return null;
    }
  }

  /// Update super key
  static Future<bool> updateSuperKey(String newSuperKey) async {
    try {
      await _firestore
          .collection('super_admin')
          .doc('config')
          .set({
        'superKey': newSuperKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error updating super key: $e');
      return false;
    }
  }

  /// Verify super key
  static Future<bool> verifySuperKey(String superKey) async {
    try {
      final storedSuperKey = await getSuperKey();
      return storedSuperKey == superKey;
    } catch (e) {
      print('Error verifying super key: $e');
      return false;
    }
  }

  /// Create super admin account
  static Future<bool> createSuperAdmin(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      await _firestore
          .collection('super_admin')
          .doc(username)
          .set({
        'username': username,
        'hashedPassword': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'super_admin',
      });

      return true;
    } catch (e) {
      print('Error creating super admin: $e');
      return false;
    }
  }

  /// Check if super admin exists
  static Future<bool> superAdminExists() async {
    try {
      final querySnapshot = await _firestore
          .collection('super_admin')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking super admin existence: $e');
      return false;
    }
  }

  /// Update super admin profile
  static Future<bool> updateSuperAdminProfile(String currentUsername, String newUsername, String newPassword) async {
    try {
      final hashedPassword = _hashPassword(newPassword);
      
      // Get current profile data
      final currentProfile = await getSuperAdminProfile(currentUsername);
      if (currentProfile == null) {
        return false;
      }

      // Check if new username already exists (if changing username)
      if (newUsername != currentUsername) {
        final existingProfile = await getSuperAdminProfile(newUsername);
        if (existingProfile != null) {
          return false; // Username already exists
        }
      }

      // Update the document
      await _firestore
          .collection('super_admin')
          .doc(currentUsername)
          .update({
        'username': newUsername,
        'hashedPassword': hashedPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If username changed, we need to create a new document and delete the old one
      if (newUsername != currentUsername) {
        // Create new document with new username
        await _firestore
            .collection('super_admin')
            .doc(newUsername)
            .set({
          'username': newUsername,
          'hashedPassword': hashedPassword,
          'fullName': currentProfile['fullName'] ?? '',
          'role': currentProfile['role'] ?? 'super_admin',
          'createdAt': currentProfile['createdAt'],
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Delete old document
        await _firestore
            .collection('super_admin')
            .doc(currentUsername)
            .delete();
      }

      return true;
    } catch (e) {
      print('Error updating super admin profile: $e');
      return false;
    }
  }

  /// Get super admin profile data
  static Future<Map<String, dynamic>?> getSuperAdminProfile(String username) async {
    try {
      final doc = await _firestore
          .collection('super_admin')
          .doc(username)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting super admin profile: $e');
      return null;
    }
  }
} 