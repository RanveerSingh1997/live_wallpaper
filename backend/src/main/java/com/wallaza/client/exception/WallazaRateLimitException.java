package com.wallaza.client.exception;

import java.util.Map;

/**
 * Thrown when the client exceeds the Wallaza rate limit tier (HTTP 429).
 */
public class WallazaRateLimitException extends WallazaException {

    private final Long limit;
    private final Long remaining;
    private final Long resetAt;

    public WallazaRateLimitException(String message, String errorCode, Map<String, Object> additionalInfo) {
        super(message, 429, errorCode, additionalInfo);
        this.limit = parseLong(additionalInfo, "limit");
        this.remaining = parseLong(additionalInfo, "remaining");
        this.resetAt = parseLong(additionalInfo, "reset_at");
    }

    private static Long parseLong(Map<String, Object> map, String key) {
        if (map == null || !map.containsKey(key)) return null;
        Object val = map.get(key);
        if (val instanceof Number n) {
            return n.longValue();
        }
        try {
            return Long.parseLong(val.toString());
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    public Long getLimit() {
        return limit;
    }

    public Long getRemaining() {
        return remaining;
    }

    public Long getResetAt() {
        return resetAt;
    }
}
