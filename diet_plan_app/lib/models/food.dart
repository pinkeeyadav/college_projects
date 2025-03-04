class Food {
  final int id;
  final String title;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String imageUrl;
  final String mealType;

  Food({
    required this.id,
    required this.title,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.imageUrl,
    required this.mealType,
  });

  // Factory method to create an instance from a JSON response
  factory Food.fromJson(Map<String, dynamic> json, String mealType) {
    return Food(
      id: json['id'],
      title: json['title'] as String,
      calories: _parseNutrient(json['calories']),
      protein: _parseNutrient(json['protein']),
      fat: _parseNutrient(json['fat']),
      carbs: _parseNutrient(json['carbs']),
      imageUrl: json['image'] as String,
      mealType: mealType,
      
    );
  }

  // Helper method to parse nutrient value from a string
  static double _parseNutrient(dynamic nutrient) {
    if (nutrient is String) {
      final cleanedString = nutrient.replaceAll(RegExp(r'[^\d.]'), ''); // Remove non-numeric characters
      return double.tryParse(cleanedString) ?? 0.0; // Convert to double, default to 0.0 if parsing fails
    }
    return (nutrient as num).toDouble(); // Handle if nutrient is already a number
  }
}