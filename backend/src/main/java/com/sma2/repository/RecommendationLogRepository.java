package com.sma2.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.sma2.entity.RecommendationLog;

public interface RecommendationLogRepository extends JpaRepository<RecommendationLog, UUID> {
	Optional<RecommendationLog> findFirstByUserIdOrderByCreatedAtDesc(UUID userId);
}
