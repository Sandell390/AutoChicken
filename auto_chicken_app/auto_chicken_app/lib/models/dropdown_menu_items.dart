import 'package:flutter/material.dart';
import 'package:auto_chicken_app/details/dropdown_menu_item.dart';

class DropdownMenuItems {
  //The names to put in the dropdown menu.
  static const List<HGDropdownMenuItem> itemsWater = [
    itemWater,
  ];

  static const List<HGDropdownMenuItem> itemsFood = [
    itemFood,
  ];

  static const List<HGDropdownMenuItem> itemsLight = [
    itemLight,
  ];

  static const List<HGDropdownMenuItem> itemsTemperature = [
    itemTemperature,
  ];

  static const List<HGDropdownMenuItem> itemsChecklist = [
    itemChecklist,
  ];

  static const List<HGDropdownMenuItem> itemsWarnings = [
    itemWarnings,
  ];

  //The icon location and name of the items going into the dropdown menu.
  static const itemWater = HGDropdownMenuItem(
    text: 'Water',
    icon: ImageIcon(
      AssetImage('assets/images/WaterIcon.png'),
      color: Colors.black87,
    ),
  );

  static const itemFood = HGDropdownMenuItem(
    text: 'Food',
    icon: ImageIcon(
      AssetImage('assets/images/ChickenfoodIcon.png'),
      color: Colors.black87,
    ),
  );

  static const itemLight = HGDropdownMenuItem(
    text: 'Light',
    icon: ImageIcon(
      AssetImage('assets/images/LightIcon.png'),
      color: Colors.black87,
    ),
  );

  static const itemTemperature = HGDropdownMenuItem(
    text: 'Temperature',
    icon: ImageIcon(
      AssetImage('assets/images/ThermometorIcon.png'),
      color: Colors.black87,
    ),
  );

  static const itemChecklist = HGDropdownMenuItem(
    text: 'Checklist',
    icon: ImageIcon(
      AssetImage('assets/images/ChecklistIcon.png'),
      color: Colors.black87,
    ),
  );

  static const itemWarnings = HGDropdownMenuItem(
    text: 'Warnings',
    icon: ImageIcon(
      AssetImage('assets/images/WarningIcon.png'),
      color: Colors.black87,
    ),
  );
}
