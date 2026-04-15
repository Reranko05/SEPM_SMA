package com.sma2.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.sma2.entity.Restaurant;

public interface RestaurantRepository extends JpaRepository<Restaurant, UUID> {

	@Query("SELECT DISTINCT r FROM Restaurant r JOIN FETCH r.menuItems")
	List<Restaurant> findAllWithMenuItems();
}
