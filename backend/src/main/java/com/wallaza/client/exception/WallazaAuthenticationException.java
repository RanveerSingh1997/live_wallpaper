package com.wallaza.client.exception;

import java.util.Map;

/**
 * Thrown when the Wallaza API returns HTTP 401 Unauthorized (e.g. invalid or missing API key).
 */
public class WallazaAuthenticationException extends WallazaException {
    public WallazaAuthenticationException(String message, String errorCode, Map<String, Object> additionalInfo) {
        super(message, 401, errorCode, additionalInfo);
    }
}
