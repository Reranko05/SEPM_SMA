package com.sma2;

import java.util.Collections;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import com.sma2.entity.DietType;
import com.sma2.entity.User;
import com.sma2.entity.UserPreferences;
import com.sma2.foodapi.FoodProviderService;
import com.sma2.foodapi.model.Meal;
import com.sma2.repository.RecommendationLogRepository;
import com.sma2.repository.UserPreferencesRepository;
import com.sma2.repository.UserRepository;
import com.sma2.service.impl.RecommendationServiceImpl;

@ExtendWith(MockitoExtension.class)
class RecommendationServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserPreferencesRepository prefsRepo;

    @Mock
    private FoodProviderService foodProviderService;

    @Mock
    private RecommendationLogRepository logRepo;

    @InjectMocks
    private RecommendationServiceImpl recommendationService;

    @Test
    void recommendForUser_withPrefs_returnsMeal() {

        // Arrange
        UUID userId = UUID.randomUUID();

        User u = new User();
        u.setId(userId);
        u.setUsername("testuser");

        UserPreferences p = new UserPreferences();
        p.setUser(u);
        p.setDietType(DietType.OMNIVORE);
        p.setCalorieLimit(1000);
        p.setBudget(20);

        Mockito.when(prefsRepo.findByUserId(userId)) // <-- FIXED
                .thenReturn(Optional.of(p));

        // Mock food API
        Meal meal = new Meal();
        meal.setId("meal1");
        meal.setCalories(500);
        meal.setPrice(10);
        meal.setDietType(DietType.OMNIVORE);

        Mockito.when(foodProviderService.fetchMeals()) // <-- FIXED
                .thenReturn(Collections.singletonList(meal));

        // Act
        Optional<Meal> maybe = recommendationService.recommendForUser(userId);

        // Assert
        Assertions.assertTrue(maybe.isPresent());
        Assertions.assertNotNull(maybe.get().getId());
    }
}