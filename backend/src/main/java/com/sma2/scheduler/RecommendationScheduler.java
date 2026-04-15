package com.sma2.scheduler;

import com.sma2.service.RecommendationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@EnableScheduling
public class RecommendationScheduler {

    private static final Logger log = LoggerFactory.getLogger(RecommendationScheduler.class);

    private final RecommendationService recommendationService;

    public RecommendationScheduler(RecommendationService recommendationService) {
        this.recommendationService = recommendationService;
    }

    @Scheduled(cron = "0 0 8,13,20 * * *")
    public void runRecommendationForAllUsers() {
        log.info("Scheduler triggered: running recommendations (demo: single test user)");
        // For demo, assume a single user id; real system would iterate Users
        try {
            UUID demoUser = UUID.fromString("00000000-0000-0000-0000-000000000000");
            recommendationService.recommendForUser(demoUser).ifPresent(meal -> log.info("Recommended: {}", meal.getName()));
        } catch (Exception e) {
            log.warn("Scheduler demo user not available");
        }
    }
}
