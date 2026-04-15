package com.sma2.config;

import java.util.ArrayList;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import com.sma2.entity.MenuItem;
import com.sma2.entity.Restaurant;
import com.sma2.repository.RestaurantRepository;

@Component
@Profile("dev")
public class DataLoader implements CommandLineRunner {

    private final RestaurantRepository restaurantRepo;

    public DataLoader(RestaurantRepository restaurantRepo) {
        this.restaurantRepo = restaurantRepo;
    }

    @Override
    public void run(String... args) throws Exception {
        if (restaurantRepo.count() > 0) return; // already seeded

        List<Restaurant> list = new ArrayList<>();

        list.add(build("Sunrise Deli", "Cafe", "https://picsum.photos/seed/r1/600/300", new String[][]{
            {"Avocado Toast","420","6.5","4.2","VEGETARIAN","8","30"},
            {"Berry Smoothie","180","4.0","4.0","VEGAN","3","35"},
            {"Egg Benedict","610","8.5","4.3","OMNIVORE","20","45"}
        }));

        list.add(build("Green Bowl", "Healthy", "https://picsum.photos/seed/r2/600/300", new String[][]{
            {"Quinoa Salad","350","7.0","4.5","VEGETARIAN","12","40"},
            {"Kale Caesar","300","6.5","4.1","VEGETARIAN","6","12"},
            {"Grilled Chicken Bowl","650","9.5","4.6","OMNIVORE","45","55"}
        }));

        list.add(build("Spice Route", "Indian", "https://picsum.photos/seed/r3/600/300", new String[][]{
            {"Butter Chicken","700","10.0","4.7","OMNIVORE","35","40"},
            {"Chana Masala","420","6.5","4.4","VEGETARIAN","12","50"},
            {"Lamb Biryani","850","12.0","4.6","OMNIVORE","40","90"}
        }));

        list.add(build("Noodle House", "Asian", "https://picsum.photos/seed/r4/600/300", new String[][]{
            {"Beef Ramen","680","9.0","4.3","OMNIVORE","30","70"},
            {"Tofu Stir Fry","410","7.5","4.2","VEGAN","18","30"},
            {"Pork Bao","520","5.5","4.0","OMNIVORE","20","45"}
        }));

        list.add(build("Bella Pasta", "Italian", "https://picsum.photos/seed/r5/600/300", new String[][]{
            {"Spaghetti Carbonara","800","11.0","4.5","OMNIVORE","28","95"},
            {"Margherita Pizza","700","9.0","4.6","VEGETARIAN","22","80"},
            {"Pesto Penne","560","8.0","4.1","VEGETARIAN","10","65"}
        }));

        list.add(build("Sushi Corner", "Japanese", "https://picsum.photos/seed/r6/600/300", new String[][]{
            {"Salmon Nigiri","120","3.5","4.8","PESCATARIAN","8","2"},
            {"Veggie Roll","200","5.0","4.0","VEGETARIAN","3","40"},
            {"Dragon Roll","450","10.0","4.5","OMNIVORE","18","60"}
        }));

        list.add(build("Taco Town", "Mexican", "https://picsum.photos/seed/r7/600/300", new String[][]{
            {"Carne Asada Taco","320","3.0","4.2","OMNIVORE","18","24"},
            {"Veggie Tacos","290","2.5","4.0","VEGETARIAN","6","30"},
            {"Churros","480","3.5","4.3","VEGETARIAN","4","70"}
        }));

        list.add(build("The Grill", "BBQ", "https://picsum.photos/seed/r8/600/300", new String[][]{
            {"Smoked Brisket","900","14.0","4.7","OMNIVORE","60","10"},
            {"BBQ Ribs","1100","15.0","4.6","OMNIVORE","58","8"},
            {"Coleslaw","200","3.0","3.9","VEGETARIAN","2","15"}
        }));

        list.add(build("Falafel King", "Middle Eastern", "https://picsum.photos/seed/r9/600/300", new String[][]{
            {"Falafel Plate","520","6.0","4.4","VEGETARIAN","18","60"},
            {"Hummus","220","4.0","4.1","VEGETARIAN","6","18"},
            {"Shawarma","640","7.5","4.3","OMNIVORE","35","45"}
        }));

        list.add(build("Dessert Studio", "Desserts", "https://picsum.photos/seed/r10/600/300", new String[][]{
            {"Cheesecake","420","5.5","4.6","VEGETARIAN","6","35"},
            {"Chocolate Lava Cake","480","6.0","4.7","VEGETARIAN","7","55"},
            {"Fruit Tart","300","4.5","4.2","VEGETARIAN","3","28"}
        }));

        restaurantRepo.saveAll(list);
        System.out.println("Seeded restaurants: " + list.size());
    }

    private Restaurant build(String name, String cuisine, String imageUrl, String[][] items) {
        Restaurant r = new Restaurant();
        r.setName(name);
        r.setCuisine(cuisine);
        r.setImageUrl(imageUrl);
        r.setRating(4.2);

        for (String[] it : items) {
            MenuItem mi = new MenuItem();
            mi.setName(it[0]);
            mi.setCalories(Integer.parseInt(it[1]));
            mi.setPrice(Double.parseDouble(it[2]));
            mi.setRating(Double.parseDouble(it[3]));
            mi.setDietType(it[4]);
            if (it.length > 5) {
                mi.setProteinGrams(Integer.parseInt(it[5]));
            }
            if (it.length > 6) {
                mi.setCarbsGrams(Integer.parseInt(it[6]));
            }
            mi.setRestaurant(r);
            r.getMenuItems().add(mi);
        }
        return r;
    }
}
