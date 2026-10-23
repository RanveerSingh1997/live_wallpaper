package com.wallaza.exception;

import com.wallaza.client.exception.*;
import com.wallaza.client.model.WallazaErrorResponse;
import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

/**
 * Intercepts application exceptions and translates them into uniform Wallaza error responses.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(WallazaAuthenticationException.class)
    public ResponseEntity<WallazaErrorResponse> handleAuthException(WallazaAuthenticationException ex) {
        return buildErrorResponse(HttpStatus.UNAUTHORIZED, ex.getErrorCode(), ex.getMessage(), ex.getAdditionalInfo());
    }

    @ExceptionHandler(WallazaForbiddenException.class)
    public ResponseEntity<WallazaErrorResponse> handleForbiddenException(WallazaForbiddenException ex) {
        return buildErrorResponse(HttpStatus.FORBIDDEN, ex.getErrorCode(), ex.getMessage(), ex.getAdditionalInfo());
    }

    @ExceptionHandler(WallazaNotFoundException.class)
    public ResponseEntity<WallazaErrorResponse> handleNotFoundException(WallazaNotFoundException ex) {
        return buildErrorResponse(HttpStatus.NOT_FOUND, ex.getErrorCode(), ex.getMessage(), ex.getAdditionalInfo());
    }

    @ExceptionHandler(WallazaRateLimitException.class)
    public ResponseEntity<WallazaErrorResponse> handleRateLimitException(WallazaRateLimitException ex) {
        HttpHeaders headers = new HttpHeaders();
        if (ex.getResetAt() != null) {
            headers.add("X-RateLimit-Reset", String.valueOf(ex.getResetAt()));
        }
        return new ResponseEntity<>(
                new WallazaErrorResponse(new WallazaErrorResponse.ErrorDetail(
                        ex.getErrorCode(),
                        ex.getMessage(),
                        429,
                        ex.getAdditionalInfo()
                )),
                headers,
                HttpStatus.TOO_MANY_REQUESTS
        );
    }

    @ExceptionHandler(WallazaValidationException.class)
    public ResponseEntity<WallazaErrorResponse> handleValidationException(WallazaValidationException ex) {
        return buildErrorResponse(HttpStatus.BAD_REQUEST, ex.getErrorCode(), ex.getMessage(), ex.getAdditionalInfo());
    }

    @ExceptionHandler({ConstraintViolationException.class, MissingServletRequestParameterException.class, IllegalArgumentException.class})
    public ResponseEntity<WallazaErrorResponse> handleClientInputException(Exception ex) {
        return buildErrorResponse(HttpStatus.BAD_REQUEST, "invalid_request", ex.getMessage(), Map.of());
    }

    @ExceptionHandler(WallazaServerException.class)
    public ResponseEntity<WallazaErrorResponse> handleServerException(WallazaServerException ex) {
        return buildErrorResponse(HttpStatus.BAD_GATEWAY, ex.getErrorCode(), ex.getMessage(), ex.getAdditionalInfo());
    }

    @ExceptionHandler(WallazaException.class)
    public ResponseEntity<WallazaErrorResponse> handleGenericWallazaException(WallazaException ex) {
        HttpStatus status = HttpStatus.resolve(ex.getStatusCode());
        if (status == null) status = HttpStatus.INTERNAL_SERVER_ERROR;
        return buildErrorResponse(status, ex.getErrorCode(), ex.getMessage(), ex.getAdditionalInfo());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<WallazaErrorResponse> handleFallback(Exception ex) {
        return buildErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR, "server_error", ex.getMessage(), Map.of());
    }

    private ResponseEntity<WallazaErrorResponse> buildErrorResponse(HttpStatus status, String code, String message, Map<String, Object> additionalInfo) {
        WallazaErrorResponse body = new WallazaErrorResponse(
                new WallazaErrorResponse.ErrorDetail(code, message, status.value(), additionalInfo)
        );
        return new ResponseEntity<>(body, status);
    }
}
