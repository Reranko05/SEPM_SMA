package com.sma2.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/v1/ai")
public class AiInsightController {

    @Value("${gemini.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    @PostMapping("/meal-insight")
    public Map<String, String> getInsight(@RequestBody Map<String, Object> body) {
        System.out.println("=== AI INSIGHT CALLED ===");
        System.out.println("API KEY: " + apiKey);  // add this
        System.out.println("BODY: " + body);        // add this
        try {
            String prompt = String.format(
                "The user follows a %s diet with a %s kcal limit and ₹%s budget. " +
                "The recommended meal is %s (%s kcal, ₹%s). " +
                "Respond ONLY in this exact JSON format with no markdown or extra text: " +
                "{\"insight\": \"2 sentence explanation here\", \"tip\": \"one nutritional tip here\"}",
                body.get("dietType"),
                body.get("calorieLimit"),
                body.get("budget"),
                body.get("mealName"),
                body.get("calories"),
                body.get("price")
            );

            String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + apiKey;

            Map<String, Object> part = new HashMap<>();
            part.put("text", prompt);

            Map<String, Object> content = new HashMap<>();
            content.put("parts", List.of(part));

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("contents", List.of(content));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                entity,
                new org.springframework.core.ParameterizedTypeReference<Map<String, Object>>() {}
            );

            // Parse Gemini response safely
            String rawText = extractTextFromGemini(response.getBody());

            // Gemini returns JSON string — parse it
            rawText = rawText.trim();
            if (rawText.startsWith("```")) {
                rawText = rawText.replaceAll("```json", "").replaceAll("```", "").trim();
            }

            // Simple JSON string extraction (no extra library needed)
            String insight = extractJsonField(rawText, "insight");
            String tip = extractJsonField(rawText, "tip");

            Map<String, String> result = new HashMap<>();
            result.put("insight", insight);
            result.put("tip", tip);
            return result;

        } catch (Exception e) {
            System.out.println("Gemini error: " + e.getMessage());
            Map<String, String> empty = new HashMap<>();
            empty.put("insight", "");
            empty.put("tip", "");
            return empty;
        }
    }

    @SuppressWarnings("unchecked")
    private String extractTextFromGemini(Map<String, Object> body) {
        try {
            List<Map<String, Object>> candidates =
                (List<Map<String, Object>>) body.get("candidates");
            Map<String, Object> content =
                (Map<String, Object>) candidates.get(0).get("content");
            List<Map<String, Object>> parts =
                (List<Map<String, Object>>) content.get("parts");
            return (String) parts.get(0).get("text");
        } catch (Exception e) {
            return "{\"insight\": \"\", \"tip\": \"\"}";
        }
    }

    private String extractJsonField(String json, String field) {
        try {
            String search = "\"" + field + "\"";
            int idx = json.indexOf(search);
            if (idx == -1) return "";
            int colon = json.indexOf(":", idx);
            int start = json.indexOf("\"", colon) + 1;
            int end = json.indexOf("\"", start);
            return json.substring(start, end);
        } catch (Exception e) {
            return "";
        }
    }
}