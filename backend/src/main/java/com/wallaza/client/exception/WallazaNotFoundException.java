package com.wallaza.client.exception;

import java.util.Map;

/**
 * Thrown when the requested wallpaper resource is not found (HTTP 404).
 */
public class WallazaNotFoundException extends WallazaException {
    public WallazaNotFoundException(String message, String errorCode, Map<String, Object> additionalInfo) {
        super(message, 404, errorCode, additionalInfo);
    }
}
