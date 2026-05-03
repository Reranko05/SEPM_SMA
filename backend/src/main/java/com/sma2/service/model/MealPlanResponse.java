package com.sma2.service.model;

import java.util.ArrayList;
import java.util.List;

public class MealPlanResponse {
    private List<MealDto> items = new ArrayList<>();
    private double totalCalories;
    private double totalProtein;
    private double totalCarbs;
    private double totalPrice;

    public MealPlanResponse() {}

    public List<MealDto> getItems() { return items; }
    public void setItems(List<MealDto> items) { this.items = items; }
    public double getTotalCalories() { return totalCalories; }
    public void setTotalCalories(double totalCalories) { this.totalCalories = totalCalories; }
    public double getTotalProtein() { return totalProtein; }
    public void setTotalProtein(double totalProtein) { this.totalProtein = totalProtein; }
    public double getTotalCarbs() { return totalCarbs; }
    public void setTotalCarbs(double totalCarbs) { this.totalCarbs = totalCarbs; }
    public double getTotalPrice() { return totalPrice; }
    public void setTotalPrice(double totalPrice) { this.totalPrice = totalPrice; }
}
