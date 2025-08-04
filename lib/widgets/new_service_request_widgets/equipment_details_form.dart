// import 'package:flutter/material.dart';
// import 'custom_text_field.dart';
// import 'form_card.dart';
// import 'custom_dropdown.dart';

// class EquipmentDetailsForm extends StatefulWidget {
//   final TextEditingController modelController;
//   final TextEditingController cityController;
//   final TextEditingController stateController;
//   final TextEditingController ownerController;
//   final TextEditingController awgSerialNumberController;
//   final bool demoMode;

//   const EquipmentDetailsForm({
//     super.key,
//     required this.modelController,
//     required this.cityController,
//     required this.stateController,
//     required this.ownerController,
//     required this.awgSerialNumberController,
//     this.demoMode = false,
//   });

//   @override
//   State<EquipmentDetailsForm> createState() => _EquipmentDetailsFormState();
// }

// class _EquipmentDetailsFormState extends State<EquipmentDetailsForm> {
//   final List<Map<String, String>> _sampleEquipment = [
//     {
//       'model': 'Printer XYZ-2000',
//       'city': 'New York',
//       'state': 'NY',
//       'owner': 'John Smith',
//       'serialNumber': 'SN12345678',
//     },
//     {
//       'model': 'Scanner ABC-100',
//       'city': 'Chicago',
//       'state': 'IL',
//       'owner': 'Sarah Johnson',
//       'serialNumber': 'SC98765432',
//     },
//     {
//       'model': 'Copier DEF-300',
//       'city': 'Los Angeles',
//       'state': 'CA',
//       'owner': 'Mike Williams',
//       'serialNumber': 'CP45612378',
//     },
//   ];

//   String? _selectedModel;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.demoMode) {
//       final matching = _sampleEquipment.firstWhere(
//         (e) => e['model'] == widget.modelController.text,
//         orElse: () => _sampleEquipment.first,
//       );
//       _fillSampleData(matching);
//       _selectedModel = matching['model'];
//     } else {
//       _selectedModel = widget.modelController.text.isNotEmpty
//           ? widget.modelController.text
//           : null;
//     }
//   }

//   void _fillSampleData(Map<String, String> equipment) {
//     widget.modelController.text = equipment['model']!;
//     widget.cityController.text = equipment['city']!;
//     widget.stateController.text = equipment['state']!;
//     widget.ownerController.text = equipment['owner']!;
//     widget.awgSerialNumberController.text = equipment['awgSerialNumber']!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FormCard(
//       title: 'Equipment Details',
//       child: Column(
//         children: [
//           if (widget.demoMode)
//             Column(
//               children: [
//                 CustomDropdown(
//                   label: 'Model',
//                   hint: 'Select equipment model',
//                   items: _sampleEquipment.map((e) => e['model']!).toList(),
//                   value: _sampleEquipment
//                           .map((e) => e['model']!)
//                           .contains(_selectedModel)
//                       ? _selectedModel
//                       : null,
//                   onChanged: (String? value) {
//                     if (value != null) {
//                       final selected = _sampleEquipment.firstWhere(
//                         (e) => e['model'] == value,
//                       );
//                       _fillSampleData(selected);
//                       setState(() {
//                         _selectedModel = value;
//                       });
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             )
//           else
//             CustomTextField(
//               label: 'Model',
//               controller: widget.modelController,
//               enabled: false,
//             ),
//           const SizedBox(height: 12),
//           CustomTextField(
//             enabled: true,
//             label: 'City',
//             controller: widget.cityController,
//             validator: (value) =>
//                 (value == null || value.isEmpty) ? 'Please enter city' : null,
//           ),
//           const SizedBox(height: 12),
//           CustomTextField(
//             label: 'State',
//             controller: widget.stateController,
//             validator: (value) =>
//                 (value == null || value.isEmpty) ? 'Please enter state' : null,
//           ),
//           const SizedBox(height: 12),
//           CustomTextField(
//             label: 'Owner',
//             controller: widget.ownerController,
//             validator: (value) => (value == null || value.isEmpty)
//                 ? 'Please enter owner name'
//                 : null,
//           ),
//           const SizedBox(height: 12),
//           CustomTextField(
//             label: 'AWG Serial Number',
//             controller: widget.awgSerialNumberController,
//             validator: (value) => (value == null || value.isEmpty)
//                 ? 'Please enter serial number'
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }
// }
