package com.wallaza.client.exception;

import java.util.Map;

/**
 * Base exception for all errors encountered when interacting with the Wallaza API.
 */
public class WallazaException extends RuntimeException {

    private final int statusCode;
    private final String errorCode;
    private final Map<String, Object> additionalInfo;

    public WallazaException(String message, int statusCode, String errorCode, Map<String, Object> additionalInfo) {
        super(message);
        this.statusCode = statusCode;
        this.errorCode = errorCode;
        this.additionalInfo = additionalInfo == null ? Map.of() : Map.copyOf(additionalInfo);
    }

    public WallazaException(String message, Throwable cause) {
        super(message, cause);
        this.statusCode = 500;
        this.errorCode = "client_error";
        this.additionalInfo = Map.of();
    }

    public int getStatusCode() {
        return statusCode;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public Map<String, Object> getAdditionalInfo() {
        return additionalInfo;
    }
}
