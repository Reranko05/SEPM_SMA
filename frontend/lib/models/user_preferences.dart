class UserPreferences {
  String username;
  String dietType;
  int calorieLimit;
  double budget;
  int spiceLevel;
  int proteinGoalGrams;
  int carbsLimitGrams;

  UserPreferences({
    required this.username,
    required this.dietType,
    required this.calorieLimit,
    required this.budget,
    required this.spiceLevel,
    this.proteinGoalGrams = 50,
    this.carbsLimitGrams = 300,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'dietType': dietType,
        'calorieLimit': calorieLimit,
        'budget': budget,
      'spiceLevel': spiceLevel,
      'proteinGoalGrams': proteinGoalGrams,
      'carbsLimitGrams': carbsLimitGrams,
      };

  factory UserPreferences.empty(String username) => UserPreferences(username: username, dietType: 'OMNIVORE', calorieLimit: 2000, budget: 15.0, spiceLevel: 3);
}
