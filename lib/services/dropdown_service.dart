import 'package:cloud_firestore/cloud_firestore.dart';

class DropdownService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get dropdown values from a specific collection
  static Future<List<String>> getDropdownValues(String collectionName) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('dropdown_List')
          .doc(collectionName)
          .get();

      if (!doc.exists) {
        print('⚠️ Document $collectionName does not exist');
        return _getDefaultValues(collectionName);
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        print('⚠️ Document $collectionName has no data');
        return _getDefaultValues(collectionName);
      }

      // Extract values from the document fields
      List<String> values = [];
      data.forEach((key, value) {
        if (value is String) {
          values.add(value);
        }
      });

      // Sort by field name (01, 02, 03, etc.)
      values.sort((a, b) {
        final aKey = data.entries.firstWhere((entry) => entry.value == a).key;
        final bKey = data.entries.firstWhere((entry) => entry.value == b).key;
        return aKey.compareTo(bKey);
      });

      print('✅ Fetched ${values.length} values from $collectionName: $values');
      return values;
    } catch (e) {
      print('❌ Error fetching dropdown values for $collectionName: $e');
      // Return default values if Firebase fails
      return _getDefaultValues(collectionName);
    }
  }

  /// Get power source values
  static Future<List<String>> getPowerSourceValues() async {
    return getDropdownValues('Power_source');
  }

  /// Get model values
  static Future<List<String>> getModelValues() async {
    return getDropdownValues('model');
  }

  /// Get dispenser values
  static Future<List<String>> getDispenserValues() async {
    return getDropdownValues('dispenser');
  }

  /// Get designation values
  static Future<List<String>> getDesignationValues() async {
    return getDropdownValues('designation_admin');
  }

  /// Get AMC type values
  static Future<List<String>> getAmcTypeValues() async {
    return getDropdownValues('amc_type');
  }

  /// Default values if Firebase is not available
  static List<String> _getDefaultValues(String collectionName) {
    switch (collectionName) {
      case 'Power_source':
        return ['EB supply', 'Solar', 'Hybrid'];
      case 'model':
        return ['VJ - Home', 'VJ - Plus', 'VJ - Grand', 'VJ - Ultra', 'VJ - Max'];
      case 'dispenser':
        return ['YES', 'NO'];
      case 'designation_admin':
        return ['Admin', 'Technician'];
      case 'amc_type':
        return ['Basic', 'Comprehensive', 'Premium', 'Extended'];
      default:
        return [];
    }
  }

  /// Add a new dropdown value to Firebase
  static Future<bool> addDropdownValue(String collectionName, String value, int order) async {
    try {
      String fieldName = order.toString().padLeft(2, '0'); // 01, 02, 03, etc.
      
      await _firestore
          .collection('dropdown_List')
          .doc(collectionName)
          .set({
        fieldName: value,
      }, SetOptions(merge: true));

      print('✅ Added value "$value" to $collectionName as field $fieldName');
      return true;
    } catch (e) {
      print('❌ Error adding dropdown value: $e');
      return false;
    }
  }

  /// Update dropdown value in Firebase
  static Future<bool> updateDropdownValue(String collectionName, String fieldName, String newValue) async {
    try {
      await _firestore
          .collection('dropdown_List')
          .doc(collectionName)
          .update({
        fieldName: newValue,
      });

      print('✅ Updated value to "$newValue" in $collectionName field $fieldName');
      return true;
    } catch (e) {
      print('❌ Error updating dropdown value: $e');
      return false;
    }
  }

  /// Delete dropdown value from Firebase
  static Future<bool> deleteDropdownValue(String collectionName, String fieldName) async {
    try {
      await _firestore
          .collection('dropdown_List')
          .doc(collectionName)
          .update({
        fieldName: FieldValue.delete(),
      });

      print('✅ Deleted field $fieldName from $collectionName');
      return true;
    } catch (e) {
      print('❌ Error deleting dropdown value: $e');
      return false;
    }
  }
}
