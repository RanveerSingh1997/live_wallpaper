package com.wallaza.client.exception;

import java.util.Map;

/**
 * Thrown when the remote Wallaza server fails internally (HTTP 500+).
 */
public class WallazaServerException extends WallazaException {
    public WallazaServerException(String message, int status, String errorCode, Map<String, Object> additionalInfo) {
        super(message, status, errorCode, additionalInfo);
    }
}
