import 'package:flutter/material.dart';

Widget getIconForPreference(String preference) {
  switch (preference) {
    case 'Instant Approval':
      return Icon(Icons.flash_on); // Lightning bolt icon
    case 'Smoking is Allowed':
      return Icon(Icons.smoking_rooms_outlined);// Smoking room icon
    case 'Smoking is Not-Allowed':
      return Icon(Icons.smoke_free);
    case 'Music is Allowed':
      return Icon(Icons.music_note_outlined); // Music note icon
    case 'Pets are Allowed':
      return Icon(Icons.pets_outlined); // Paw icon
    default:
      return Icon(Icons.info_outline); // Default icon for unknown preferences
  }
}