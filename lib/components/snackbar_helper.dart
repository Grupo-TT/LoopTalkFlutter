  import 'package:flutter/material.dart';

 class SnackBarHelper {
       static void showErrorMessage(BuildContext context, String message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
             message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
           ),
            backgroundColor: Colors.redAccent, 
            behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
         ),
       );
     }


      static void showSuccesssMessage(BuildContext context, String message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
             message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
           ),
            backgroundColor: const Color(0xFF4CAF50), 
            behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
         ),
       );
     }

     static void showInfoMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF2196F3), 
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
    ),
  );
}
     
    }