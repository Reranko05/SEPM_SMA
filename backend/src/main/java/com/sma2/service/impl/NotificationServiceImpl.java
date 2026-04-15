package com.sma2.service.impl;

import com.sma2.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class NotificationServiceImpl implements NotificationService {
    private static final Logger log = LoggerFactory.getLogger(NotificationServiceImpl.class);

    @Override
    public void notifyUser(String userId, String message) {
        log.info("[MockNotification] user={} message={}", userId, message);
    }
}
