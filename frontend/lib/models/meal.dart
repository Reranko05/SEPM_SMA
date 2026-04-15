class Meal {
  final String id;
  final String name;
  final int calories;
  final double price;
  final double rating;
  final String dietType;

  Meal({required this.id, required this.name, required this.calories, required this.price, required this.rating, required this.dietType});

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        calories: (json['calories'] ?? 0) as int,
        price: (json['price'] ?? 0).toDouble(),
        rating: (json['rating'] ?? 0).toDouble(),
        dietType: json['dietType'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'price': price,
        'rating': rating,
        'dietType': _normalizeDiet(dietType),
      };

  String _normalizeDiet(String d) {
    final s = d.trim().toUpperCase();
    if (s == 'VEG' || s == 'VEGETARIAN') return 'VEGETARIAN';
    if (s == 'NON-VEG' || s == 'OMNIVORE') return 'OMNIVORE';
    if (s == 'VEGAN') return 'VEGAN';
    if (s.startsWith('PESC')) return 'PESCATARIAN';
    return s;
  }
}
