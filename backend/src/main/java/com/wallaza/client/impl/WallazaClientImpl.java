package com.wallaza.client.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wallaza.client.WallazaClient;
import com.wallaza.client.exception.WallazaAuthenticationException;
import com.wallaza.client.exception.WallazaException;
import com.wallaza.client.exception.WallazaForbiddenException;
import com.wallaza.client.exception.WallazaNotFoundException;
import com.wallaza.client.exception.WallazaRateLimitException;
import com.wallaza.client.exception.WallazaServerException;
import com.wallaza.client.exception.WallazaValidationException;
import com.wallaza.client.model.Wallpaper;
import com.wallaza.client.model.WallpaperListQuery;
import com.wallaza.client.model.WallpaperListResponse;
import com.wallaza.client.model.WallpaperSearchQuery;
import com.wallaza.client.model.WallpaperSingleResponse;
import com.wallaza.client.model.WallazaErrorResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.web.client.RestClient;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import java.util.Objects;

/**
 * Modern Spring {@link RestClient} based implementation of {@link WallazaClient}.
 */
public class WallazaClientImpl implements WallazaClient {

    private final RestClient restClient;
    private final RestClient rawClient;
    private final ObjectMapper objectMapper;

    public WallazaClientImpl(String apiKey, String baseUrl, ObjectMapper objectMapper, RestClient.Builder restClientBuilder) {
        Objects.requireNonNull(baseUrl, "baseUrl must not be null");
        this.objectMapper = objectMapper != null ? objectMapper : new ObjectMapper().findAndRegisterModules();

        RestClient.Builder builder = restClientBuilder != null ? restClientBuilder.clone() : RestClient.builder();

        builder.baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .defaultStatusHandler(HttpStatusCode::isError, this::handleErrorResponse);

        if (apiKey != null && !apiKey.isBlank()) {
            builder.defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey.trim());
        }

        this.restClient = builder.build();

        // Secondary client used for downloading raw media bytes from external CDN URLs
        this.rawClient = RestClient.builder().build();
    }

    public WallazaClientImpl(String apiKey, String baseUrl) {
        this(apiKey, baseUrl, null, null);
    }

    public WallazaClientImpl(String apiKey) {
        this(apiKey, "https://api.wallaza.com/v1");
    }

    @Override
    public WallpaperListResponse listWallpapers(WallpaperListQuery query) {
        final WallpaperListQuery q = query != null ? query : new WallpaperListQuery(1, 20, null);

        return restClient.get()
                .uri(uriBuilder -> {
                    uriBuilder.path("/wallpapers");
                    if (q.page() != null && q.page() > 0) {
                        uriBuilder.queryParam("page", q.page());
                    }
                    if (q.limit() != null && q.limit() > 0) {
                        uriBuilder.queryParam("limit", q.limit());
                    }
                    if (q.category() != null && !q.category().isBlank()) {
                        uriBuilder.queryParam("category", q.category().trim());
                    }
                    return uriBuilder.build();
                })
                .retrieve()
                .body(WallpaperListResponse.class);
    }

    @Override
    public WallpaperListResponse searchWallpapers(WallpaperSearchQuery query) {
        Objects.requireNonNull(query, "Search query must not be null");

        return restClient.get()
                .uri(uriBuilder -> {
                    uriBuilder.path("/wallpapers/search");
                    uriBuilder.queryParam("query", query.query());
                    if (query.resolution() != null && !query.resolution().isBlank()) {
                        uriBuilder.queryParam("resolution", query.resolution().trim());
                    }
                    if (query.page() != null && query.page() > 0) {
                        uriBuilder.queryParam("page", query.page());
                    }
                    if (query.limit() != null && query.limit() > 0) {
                        uriBuilder.queryParam("limit", query.limit());
                    }
                    return uriBuilder.build();
                })
                .retrieve()
                .body(WallpaperListResponse.class);
    }

    @Override
    public Wallpaper getWallpaper(String wallpaperId) {
        if (wallpaperId == null || wallpaperId.isBlank()) {
            throw new IllegalArgumentException("wallpaperId must not be blank");
        }

        final String cleanId = wallpaperId.trim();

        // Handle both /wallpapers/{id} and fallback envelope
        try {
            return restClient.get()
                    .uri("/wallpapers/{id}", cleanId)
                    .retrieve()
                    .body(Wallpaper.class);
        } catch (WallazaException ex) {
            throw ex;
        } catch (Exception ex) {
            // Check if endpoint returns wrapped data (e.g. { "data": { ... } })
            try {
                WallpaperSingleResponse wrapped = restClient.get()
                        .uri("/wallpapers/{id}", cleanId)
                        .retrieve()
                        .body(WallpaperSingleResponse.class);
                if (wrapped != null && wrapped.data() != null) {
                    return wrapped.data();
                }
            } catch (Exception ignored) {
            }
            throw new WallazaException("Failed to retrieve wallpaper with id: " + cleanId, ex);
        }
    }

    @Override
    public byte[] downloadWallpaperBytes(String wallpaperId) {
        Wallpaper wallpaper = getWallpaper(wallpaperId);
        if (wallpaper == null || wallpaper.url() == null || wallpaper.url().isBlank()) {
            throw new WallazaNotFoundException("Wallpaper URL unavailable for id: " + wallpaperId, "not_found", Map.of());
        }

        return rawClient.get()
                .uri(wallpaper.url())
                .retrieve()
                .body(byte[].class);
    }

    @Override
    public InputStream downloadWallpaperStream(String wallpaperId) {
        byte[] bytes = downloadWallpaperBytes(wallpaperId);
        return new ByteArrayInputStream(bytes);
    }

    private void handleErrorResponse(org.springframework.http.HttpRequest request, ClientHttpResponse response) throws IOException {
        int status = response.getStatusCode().value();
        byte[] body = response.getBody().readAllBytes();

        String code = "error_" + status;
        String message = "HTTP " + status + " error from Wallaza API";
        Map<String, Object> additionalInfo = Map.of();

        if (body.length > 0) {
            try {
                WallazaErrorResponse errorResponse = objectMapper.readValue(body, WallazaErrorResponse.class);
                if (errorResponse != null && errorResponse.error() != null) {
                    if (errorResponse.error().code() != null) {
                        code = errorResponse.error().code();
                    }
                    if (errorResponse.error().message() != null) {
                        message = errorResponse.error().message();
                    }
                    if (errorResponse.error().additionalInfo() != null) {
                        additionalInfo = errorResponse.error().additionalInfo();
                    }
                }
            } catch (Exception ignored) {
                message = new String(body);
            }
        }

        switch (status) {
            case 400 -> throw new WallazaValidationException(message, code, additionalInfo);
            case 401 -> throw new WallazaAuthenticationException(message, code, additionalInfo);
            case 403 -> throw new WallazaForbiddenException(message, code, additionalInfo);
            case 404 -> throw new WallazaNotFoundException(message, code, additionalInfo);
            case 429 -> throw new WallazaRateLimitException(message, code, additionalInfo);
            default -> {
                if (status >= 500) {
                    throw new WallazaServerException(message, status, code, additionalInfo);
                }
                throw new WallazaException(message, status, code, additionalInfo);
            }
        }
    }
}
