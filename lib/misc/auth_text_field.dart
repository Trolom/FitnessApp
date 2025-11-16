import 'package:flutter/material.dart';


class AuthTextField extends StatelessWidget {
final TextEditingController controller;
final String label;
final TextInputType? keyboardType;
final String? Function(String?)? validator;


const AuthTextField({
super.key,
required this.controller,
required this.label,
this.keyboardType,
this.validator,
});


@override
Widget build(BuildContext context) {
return TextFormField(
controller: controller,
keyboardType: keyboardType,
decoration: InputDecoration(
labelText: label,
border: const OutlineInputBorder(),
),
validator: validator,
);
}
}