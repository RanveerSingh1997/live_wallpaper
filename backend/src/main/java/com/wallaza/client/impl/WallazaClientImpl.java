package com.wallaza.client.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.wallaza.client.WallazaClient;
import com.wallaza.client.exception.WallazaAuthenticationException;
import com.wallaza.client.exception.WallazaException;
import com.wallaza.client.exception.WallazaForbiddenException;
import com.wallaza.client.exception.WallazaNotFoundException;
import com.wallaza.client.exception.WallazaRateLimitException;
import com.wallaza.client.exception.WallazaServerException;
import com.wallaza.client.exception.WallazaValidationException;
import com.wallaza.client.model.PaginationLinks;
import com.wallaza.client.model.PaginationMeta;
import com.wallaza.client.model.Wallpaper;
import com.wallaza.client.model.WallpaperAuthor;
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
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Modern Spring {@link RestClient} based implementation of {@link WallazaClient}.
 * Supports both legacy proxy endpoints and native Pixabay API integration.
 */
public class WallazaClientImpl implements WallazaClient {

    private final RestClient restClient;
    private final RestClient rawClient;
    private final ObjectMapper objectMapper;
    private final String baseUrl;
    private final String apiKey;
    private final boolean isPixabay;

    public WallazaClientImpl(String apiKey, String baseUrl, ObjectMapper objectMapper, RestClient.Builder restClientBuilder) {
        Objects.requireNonNull(baseUrl, "baseUrl must not be null");
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
        this.isPixabay = baseUrl.contains("pixabay.com");
        this.objectMapper = objectMapper != null ? objectMapper : new ObjectMapper().findAndRegisterModules();

        RestClient.Builder builder = restClientBuilder != null ? restClientBuilder.clone() : RestClient.builder();

        builder.baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .defaultStatusHandler(HttpStatusCode::isError, this::handleErrorResponse);

        if (!isPixabay && apiKey != null && !apiKey.isBlank()) {
            builder.defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey.trim());
        }

        this.restClient = builder.build();
        this.rawClient = RestClient.builder().build();
    }

    public WallazaClientImpl(String apiKey, String baseUrl) {
        this(apiKey, baseUrl, null, null);
    }

    public WallazaClientImpl(String apiKey) {
        this(apiKey, "https://pixabay.com/api");
    }

    @Override
    public WallpaperListResponse listWallpapers(WallpaperListQuery query) {
        final WallpaperListQuery q = query != null ? query : new WallpaperListQuery(1, 20, null);

        if (isPixabay) {
            return fetchPixabayWallpapers(q.page(), q.limit(), q.category(), null);
        }

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

        if (isPixabay) {
            return fetchPixabayWallpapers(query.page(), query.limit(), null, query.query());
        }

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

        if (isPixabay) {
            return getPixabayWallpaperById(cleanId);
        }

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

    private WallpaperListResponse fetchPixabayWallpapers(Integer page, Integer limit, String category, String query) {
        final int pageNum = page != null && page > 0 ? page : 1;
        final int perPage = limit != null && limit > 0 ? Math.min(200, Math.max(3, limit)) : 20;

        String rawJson = restClient.get()
                .uri(uriBuilder -> {
                    uriBuilder.path("/");
                    if (apiKey != null && !apiKey.isBlank()) {
                        uriBuilder.queryParam("key", apiKey.trim());
                    }
                    uriBuilder.queryParam("page", pageNum);
                    uriBuilder.queryParam("per_page", perPage);
                    uriBuilder.queryParam("image_type", "all");
                    uriBuilder.queryParam("orientation", "vertical");
                    uriBuilder.queryParam("safesearch", "true");

                    if (query != null && !query.isBlank()) {
                        uriBuilder.queryParam("q", query.trim());
                    } else if (category != null && !category.isBlank() && !"all".equalsIgnoreCase(category.trim())) {
                        String mapped = mapCategoryToPixabay(category.trim());
                        if (mapped != null) {
                            uriBuilder.queryParam("category", mapped);
                        } else {
                            uriBuilder.queryParam("q", category.trim().toLowerCase());
                        }
                    }
                    return uriBuilder.build();
                })
                .retrieve()
                .body(String.class);

        return parsePixabayListResponse(rawJson, pageNum, perPage);
    }

    private Wallpaper getPixabayWallpaperById(String rawId) {
        String cleanId = rawId.startsWith("pixabay_") ? rawId.substring("pixabay_".length()) : rawId;
        String rawJson = restClient.get()
                .uri(uriBuilder -> {
                    uriBuilder.path("/");
                    if (apiKey != null && !apiKey.isBlank()) {
                        uriBuilder.queryParam("key", apiKey.trim());
                    }
                    uriBuilder.queryParam("id", cleanId);
                    return uriBuilder.build();
                })
                .retrieve()
                .body(String.class);

        WallpaperListResponse list = parsePixabayListResponse(rawJson, 1, 1);
        if (list.data().isEmpty()) {
            throw new WallazaNotFoundException("Wallpaper not found on Pixabay: " + rawId, "not_found", Map.of());
        }
        return list.data().get(0);
    }

    private WallpaperListResponse parsePixabayListResponse(String rawJson, int pageNum, int perPage) {
        try {
            JsonNode root = objectMapper.readTree(rawJson);
            long totalHits = root.path("totalHits").asLong(0);
            JsonNode hits = root.path("hits");

            List<Wallpaper> wallpapers = new ArrayList<>();
            if (hits.isArray()) {
                for (JsonNode item : hits) {
                    long idNum = item.path("id").asLong(0);
                    String id = "pixabay_" + idNum;
                    String tags = item.path("tags").asText("wallpaper");
                    String[] tagArr = tags.split(",\\s*");
                    List<String> tagList = Arrays.asList(tagArr);
                    String firstTag = tagArr.length > 0 ? tagArr[0].trim() : "Wallpaper";
                    String title = capitalize(firstTag) + " Wallpaper";

                    boolean isVideo = item.has("videos")
                            || "film".equals(item.path("type").asText())
                            || "animation".equals(item.path("type").asText());

                    String url = "";
                    String thumbnailUrl = "";
                    String videoUrl = null;
                    String resolution = "3840x2160";
                    long fileSize = 3500000L;
                    int duration = 0;

                    if (isVideo) {
                        JsonNode videos = item.path("videos");
                        JsonNode large = videos.path("large");
                        JsonNode medium = videos.path("medium");
                        JsonNode small = videos.path("small");

                        videoUrl = large.has("url") ? large.path("url").asText()
                                : (medium.has("url") ? medium.path("url").asText() : small.path("url").asText(null));
                        thumbnailUrl = large.has("thumbnail") ? large.path("thumbnail").asText()
                                : (medium.has("thumbnail") ? medium.path("thumbnail").asText() : item.path("userImageURL").asText(""));
                        url = thumbnailUrl;
                        int width = large.path("width").asInt(1920);
                        int height = large.path("height").asInt(1080);
                        resolution = width + "x" + height;
                        fileSize = large.path("size").asLong(8000000L);
                        duration = item.path("duration").asInt(15);
                    } else {
                        url = item.has("largeImageURL") ? item.path("largeImageURL").asText()
                                : (item.has("webformatURL") ? item.path("webformatURL").asText() : item.path("previewURL").asText(""));
                        thumbnailUrl = item.has("webformatURL") ? item.path("webformatURL").asText()
                                : (item.has("previewURL") ? item.path("previewURL").asText() : url);
                        int width = item.path("imageWidth").asInt(3840);
                        int height = item.path("imageHeight").asInt(2160);
                        resolution = width + "x" + height;
                        fileSize = item.path("imageSize").asLong(3500000L);
                    }

                    String category = "Abstract";
                    for (String tag : tagArr) {
                        String t = tag.trim().toLowerCase();
                        if ("nature".equals(t) || "landscape".equals(t) || "mountain".equals(t)) {
                            category = "Nature";
                            break;
                        } else if ("space".equals(t) || "galaxy".equals(t) || "stars".equals(t)) {
                            category = "Space";
                            break;
                        } else if ("cyberpunk".equals(t) || "neon".equals(t) || "city".equals(t)) {
                            category = "Cyberpunk";
                            break;
                        } else if ("amoled".equals(t) || "dark".equals(t) || "black".equals(t)) {
                            category = "AMOLED";
                            break;
                        } else if ("anime".equals(t) || "illustration".equals(t)) {
                            category = "Anime";
                            break;
                        }
                    }
                    if (isVideo && "Abstract".equals(category)) {
                        category = "Live";
                    }

                    WallpaperAuthor author = new WallpaperAuthor(
                            String.valueOf(item.path("user_id").asLong(0)),
                            item.path("user").asText("Pixabay Artist"),
                            item.path("userImageURL").asText("")
                    );

                    wallpapers.add(new Wallpaper(
                            id,
                            title,
                            "Pixabay wallpaper by " + author.name(),
                            url,
                            thumbnailUrl,
                            category,
                            tagList,
                            resolution,
                            fileSize,
                            item.path("downloads").asLong(0),
                            item.path("likes").asLong(0),
                            author,
                            Instant.now(),
                            videoUrl,
                            isVideo,
                            duration
                    ));
                }
            }

            int totalPages = totalHits > 0 ? (int) Math.ceil((double) totalHits / perPage) : 0;
            PaginationMeta meta = new PaginationMeta(pageNum, totalPages, totalHits, perPage);
            PaginationLinks links = new PaginationLinks(
                    "/wallpapers?page=1",
                    pageNum > 1 ? "/wallpapers?page=" + (pageNum - 1) : null,
                    pageNum < totalPages ? "/wallpapers?page=" + (pageNum + 1) : null,
                    totalPages > 0 ? "/wallpapers?page=" + totalPages : null
            );
            return new WallpaperListResponse(wallpapers, meta, links);
        } catch (Exception ex) {
            throw new WallazaException("Failed to parse Pixabay API response", ex);
        }
    }

    private String mapCategoryToPixabay(String category) {
        if (category == null || category.isBlank()) {
            return null;
        }
        return switch (category.trim().toLowerCase()) {
            case "nature", "landscape" -> "nature";
            case "space", "galaxy" -> "science";
            case "cyberpunk", "technology" -> "computer";
            case "urban", "architecture" -> "buildings";
            case "amoled", "minimalist" -> "backgrounds";
            case "people" -> "people";
            case "places" -> "places";
            case "animals" -> "animals";
            case "music" -> "music";
            default -> null;
        };
    }

    private String capitalize(String str) {
        if (str == null || str.isBlank()) {
            return "Wallpaper";
        }
        return str.substring(0, 1).toUpperCase() + str.substring(1);
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
