import 'package:flutter/material.dart';

class CustomCheckboxWidget extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const CustomCheckboxWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 40,
          child:Transform.scale(
            scale: 1.7,
            child: Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: Colors.blue[600],
              checkColor: Colors.white,
              side: BorderSide(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}