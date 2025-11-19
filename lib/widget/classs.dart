import 'package:flutter/material.dart';

Widget buildTitle(String text) {
  return Row(
    children: [
      Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          // color: AppColor.gray88,
        ),
      ),
    ],
  );
}

TextFormField buildTextFieldnoButton({
  String? hintText,
  bool isPassword = false,
  TextEditingController? controller,
  String? Function(String?)? validator,
  bool isVisibility = false,
}) {
  return TextFormField(
    validator: validator,
    controller: controller,
    obscureText: isPassword ? isVisibility : false,
    decoration: InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.2),
          width: 1.0,
        ),
      ),
    ),
  );
}

Widget buildTextField({
  String? hintText,
  bool isPassword = false,
  TextEditingController? controller,
  String? Function(String?)? validator,
}) {
  bool isVisible = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return TextFormField(
        validator: validator,
        controller: controller,
        obscureText: isPassword ? !isVisible : false,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: Colors.black.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: Colors.black.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() => isVisible = !isVisible);
                  },
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
        ),
      );
    },
  );
}
