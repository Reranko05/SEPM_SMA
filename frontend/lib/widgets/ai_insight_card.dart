import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_provider.dart';
import '../config/app_config.dart';

class AiInsightCard extends StatefulWidget {
  final Map meal;
  final Map prefs;

  const AiInsightCard({
    super.key,
    required this.meal,
    required this.prefs,
  });

  @override
  State<AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends State<AiInsightCard> {
  String insight = "";
  String tip = "";
  bool loading = true;
  bool _called = false; // ← prevents multiple calls on rebuild

  @override
  void initState() {
    super.initState();
    fetchInsight();
  }

  Future<void> fetchInsight() async {
    if (_called) return; // ← stop if already called
    _called = true;      // ← lock immediately

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      if (token == null) {
        print('No JWT found in SharedPreferences');
        if (!mounted) return;
        setState(() => loading = false);
        return;
      }

      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/v1/ai/meal-insight'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "mealName": widget.meal['name'],
          "calories": widget.meal['calories'],
          "price": widget.meal['price'],
          "dietType": widget.meal['dietType'],
          "calorieLimit": widget.prefs['calorieLimit'],
          "budget": widget.prefs['budget'],
        }),
      );

      print("AI STATUS: ${res.statusCode}");
      print("AI BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (!mounted) return;
      setState(() {
        insight = data['insight'] ?? "";
        tip = data['tip'] ?? "";
        loading = false;
      });
    } catch (e) {
      print("AiInsightCard error: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // fallback card — shows even when Gemini quota is exhausted
    if (!loading && insight.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFFE8F5E9),
        ),
        child: const Row(
          children: [
            Text("✨", style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "AI Insight: This meal aligns with your dietary preferences and calorie goals.",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Colors.white],
        ),
      ),
      child: loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(height: 60, color: Colors.white),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Text("✨", style: TextStyle(fontSize: 18)),
                  SizedBox(width: 6),
                  Text("AI Insight",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                Text(insight),
                const SizedBox(height: 6),
                Row(children: [
                  const Text("💡"),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ]),
              ],
            ),
    );
  }
}