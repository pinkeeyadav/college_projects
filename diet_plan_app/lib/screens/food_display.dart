


import 'package:flutter/material.dart';
import 'package:diet_plan_app/models/food.dart';
import 'package:diet_plan_app/service/api_service.dart';
import 'package:diet_plan_app/screens/recipe_detail_screen.dart';

class FoodDisplay extends StatefulWidget {
  final double minCalories;
  final double maxCalories;
  final String mealType;

  const FoodDisplay({
    super.key,
    required this.minCalories,
    required this.maxCalories,
     required this.mealType,
     }) ;

  @override
  _FoodDisplayState createState() => _FoodDisplayState();
}

class _FoodDisplayState extends State<FoodDisplay> {
  final ApiService apiService = ApiService();
  late Future<List<Food>> meals;

  @override
  void initState() {
    super.initState();
    meals = apiService.fetchMeals(widget.mealType, widget.minCalories,widget.maxCalories);
  }



  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mealType.capitalize()} Suggestions'),
        backgroundColor: Theme.of(context).colorScheme.secondaryFixedDim,
      ),
      body: FutureBuilder<List<Food>>(
        future: meals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final food = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      food.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(food.title),
                    subtitle: Text(
                      'Calories: ${food.calories} cal\n'
                      'Protein: ${food.protein}g\n'
                      'Fat: ${food.fat}g\n'
                      'Carbs: ${food.carbs}g',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                            recipeId: food.id,
                            mealType: food.mealType,
                          ),
                        ),
                      );
                    },
                    
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No meals found'));
          }
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + this.substring(1);
}  