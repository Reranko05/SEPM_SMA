package com.sma2.foodapi;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.sma2.entity.DietType;
import com.sma2.entity.MenuItem;
import com.sma2.foodapi.model.Meal;
import com.sma2.repository.MenuItemRepository;

@Service
public class MockFoodProviderService implements FoodProviderService {

    private final MenuItemRepository menuRepo;

    public MockFoodProviderService(MenuItemRepository menuRepo) {
        this.menuRepo = menuRepo;
    }

    @Override
    public List<Meal> fetchMeals() {
        List<MenuItem> items = menuRepo.findAll();
        return items.stream().map(mi -> new Meal(
            mi.getId() != null ? mi.getId().toString() : java.util.UUID.randomUUID().toString(),
            mi.getName(),
            mi.getCalories(),
            mi.getPrice(),
            mi.getRating(),
            parseDiet(mi.getDietType()),
            mi.getProteinGrams(),
            mi.getCarbsGrams()
        )).collect(Collectors.toList());
    }

    private DietType parseDiet(String s) {
        if (s == null) return DietType.OMNIVORE;
        String up = s.trim().toUpperCase();
        if (up.contains("VEGAN")) return DietType.VEGAN;
        if (up.contains("VEGET" )|| up.equals("VEG")) return DietType.VEGETARIAN;
        if (up.contains("PESC")) return DietType.PESCATARIAN;
        return DietType.OMNIVORE;
    }
}
