import 'package:cloud_firestore/cloud_firestore.dart';
import 'dropdown_service.dart';

class SetupDropdownData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize all dropdown data in Firebase
  static Future<void> initializeDropdownData() async {
    try {
      print('🚀 Starting dropdown data initialization...');
      
      // Setup power source values
      await _setupPowerSourceValues();
      
      // Setup model values
      await _setupModelValues();
      
      // Setup dispenser values
      await _setupDispenserValues();
      
      // Setup designation values
      await _setupDesignationValues();
      
      print('✅ Dropdown data initialization completed successfully!');
    } catch (e) {
      print('❌ Error initializing dropdown data: $e');
    }
  }

  /// Setup power source values
  static Future<void> _setupPowerSourceValues() async {
    try {
      print('📝 Setting up power source values...');
      
      // Create the document with all values at once
      await _firestore
          .collection('dropdown_List')
          .doc('Power_source')
          .set({
        '01': 'EB supply',
        '02': 'Solar',
        '03': 'Hybrid',
      }, SetOptions(merge: true));
      
      print('✅ Power source values setup completed');
    } catch (e) {
      print('❌ Error setting up power source values: $e');
    }
  }

  /// Setup model values
  static Future<void> _setupModelValues() async {
    try {
      print('📝 Setting up model values...');
      
      // Create the document with all values at once
      await _firestore
          .collection('dropdown_List')
          .doc('model')
          .set({
        '01': 'VJ - Home',
        '02': 'VJ - Plus',
        '03': 'VJ - Grand',
        '04': 'VJ - Ultra',
        '05': 'VJ - Max',
      }, SetOptions(merge: true));
      
      print('✅ Model values setup completed');
    } catch (e) {
      print('❌ Error setting up model values: $e');
    }
  }

  /// Setup dispenser values
  static Future<void> _setupDispenserValues() async {
    try {
      print('📝 Setting up dispenser values...');
      
      // Create the document with all values at once
      await _firestore
          .collection('dropdown_List')
          .doc('dispenser')
          .set({
        '01': 'YES',
        '02': 'NO',
      }, SetOptions(merge: true));
      
      print('✅ Dispenser values setup completed');
    } catch (e) {
      print('❌ Error setting up dispenser values: $e');
    }
  }

  /// Setup designation values
  static Future<void> _setupDesignationValues() async {
    try {
      print('📝 Setting up designation values...');
      
      // Create the document with all values at once
      await _firestore
          .collection('dropdown_List')
          .doc('Designation')
          .set({
        '01': 'Admin',
        '02': 'Technician',
      }, SetOptions(merge: true));
      
      print('✅ Designation values setup completed');
    } catch (e) {
      print('❌ Error setting up designation values: $e');
    }
  }

  /// Get all dropdown values for debugging
  static Future<void> debugDropdownValues() async {
    try {
      print('🔍 Debugging dropdown values...');
      
      final powerSourceValues = await DropdownService.getPowerSourceValues();
      final modelValues = await DropdownService.getModelValues();
      final dispenserValues = await DropdownService.getDispenserValues();
      
      print('Power Source Values: $powerSourceValues');
      print('Model Values: $modelValues');
      print('Dispenser Values: $dispenserValues');
    } catch (e) {
      print('❌ Error debugging dropdown values: $e');
    }
  }
}
