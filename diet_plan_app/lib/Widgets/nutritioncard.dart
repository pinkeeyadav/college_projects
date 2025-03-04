
import 'package:flutter/material.dart';

class NutritionCard extends StatelessWidget {
  const  NutritionCard({
    super.key,
    required this.label,
     required this.value,
      required this.color,
      });
      
  final String label;
  final String value;
  final Color color;

  

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            label[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(          
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}