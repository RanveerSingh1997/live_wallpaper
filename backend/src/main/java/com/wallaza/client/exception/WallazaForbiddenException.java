package com.wallaza.client.exception;

import java.util.Map;

/**
 * Thrown when the Wallaza API returns HTTP 403 Forbidden.
 */
public class WallazaForbiddenException extends WallazaException {
    public WallazaForbiddenException(String message, String errorCode, Map<String, Object> additionalInfo) {
        super(message, 403, errorCode, additionalInfo);
    }
}
