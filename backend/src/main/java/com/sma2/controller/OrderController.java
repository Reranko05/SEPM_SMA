package com.sma2.controller;

import com.sma2.entity.OrderEntity;
import com.sma2.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/order")
public class OrderController {

    private final com.sma2.repository.UserRepository userRepo;
    private final com.sma2.repository.OrderRepository orderRepo;
    private final NotificationService notificationService;

    public OrderController(com.sma2.repository.UserRepository userRepo,
                           com.sma2.repository.OrderRepository orderRepo,
                           NotificationService notificationService) {
        this.userRepo = userRepo;
        this.orderRepo = orderRepo;
        this.notificationService = notificationService;
    }

    @PostMapping
    public ResponseEntity<?> confirmOrder(@AuthenticationPrincipal UserDetails user) {
        java.util.Optional<com.sma2.entity.User> maybe = userRepo.findByUsername(user.getUsername());
        if (!maybe.isPresent()) return ResponseEntity.status(404).build();
        UUID userId = maybe.get().getId();
        // For demo create a minimal order record
        OrderEntity o = new OrderEntity();
        o.setUserId(userId);
        o.setMealId("auto-selected");
        o.setPrice(0.0);
        orderRepo.save(o);
        notificationService.notifyUser(userId.toString(), "Your meal is ready");
        return ResponseEntity.ok(o);
    }
}
