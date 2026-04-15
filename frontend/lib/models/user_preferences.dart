class UserPreferences {
  String username;
  String dietType;
  int calorieLimit;
  double budget;
  int spiceLevel;

  UserPreferences({
    required this.username,
    required this.dietType,
    required this.calorieLimit,
    required this.budget,
    required this.spiceLevel,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'dietType': dietType,
        'calorieLimit': calorieLimit,
        'budget': budget,
        'spiceLevel': spiceLevel,
      };

  factory UserPreferences.empty(String username) => UserPreferences(username: username, dietType: 'OMNIVORE', calorieLimit: 2000, budget: 15.0, spiceLevel: 3);
}
