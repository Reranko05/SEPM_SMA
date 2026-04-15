package com.sma2.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.sma2.entity.Restaurant;

public interface RestaurantRepository extends JpaRepository<Restaurant, UUID> {
}
