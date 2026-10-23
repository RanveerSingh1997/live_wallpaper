package com.wallaza.client.exception;

import java.util.Map;

/**
 * Thrown when the Wallaza API rejects invalid request parameters (HTTP 400).
 */
public class WallazaValidationException extends WallazaException {
    public WallazaValidationException(String message, String errorCode, Map<String, Object> additionalInfo) {
        super(message, 400, errorCode, additionalInfo);
    }
}
