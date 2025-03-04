class RecipeDetail {
  final int id;
  final String imageUrl;
  final String title;
  final int readyInMinutes;
  final int servings;
  final List<String> ingredients;
  final String instructions;
  final List<String> dietTypes;

  RecipeDetail({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.readyInMinutes,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.dietTypes,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
   /* var dietTypesFromJson = json['diets'] as List<dynamic>;
    List<String> dietTypesList = dietTypesFromJson.map((item) => item as String).toList(); */
     

    return RecipeDetail(
    //  dietTypes: dietTypesList,
      id: json['id'],
      imageUrl: json['image'] ?? '',
      title: json['title'] ?? 'No Title Available',
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      ingredients: (json['extendedIngredients'] as List<dynamic>?)
              ?.map((ingredient) => ingredient['original'] as String)
              .toList() ??
          [],
      instructions: json['instructions'] ?? 'No instructions available.',
      dietTypes:   (json['diets'] as List<dynamic>).cast<String>(),
      //dietTypesList,  
      /*as List<dynamic>?)
              ?.map((diet) => diet as String)
              .toList() ??
          [], */
    );
  }
}