package com.wallaza.client;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.wallaza.client.exception.WallazaAuthenticationException;
import com.wallaza.client.exception.WallazaNotFoundException;
import com.wallaza.client.exception.WallazaRateLimitException;
import com.wallaza.client.exception.WallazaValidationException;
import com.wallaza.client.impl.WallazaClientImpl;
import com.wallaza.client.model.Wallpaper;
import com.wallaza.client.model.WallpaperListQuery;
import com.wallaza.client.model.WallpaperListResponse;
import com.wallaza.client.model.WallpaperSearchQuery;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.*;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;

class WallazaClientTest {

    private static final String BASE_URL = "https://api.wallaza.com/v1";
    private static final String API_KEY = "test_api_key_123";

    private MockRestServiceServer server;
    private WallazaClient client;
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper().registerModule(new JavaTimeModule());
        RestClient.Builder builder = RestClient.builder();
        server = MockRestServiceServer.bindTo(builder).build();

        client = new WallazaClientImpl(API_KEY, BASE_URL, objectMapper, builder);
    }

    @Test
    @DisplayName("listWallpapers sends Authorization header and correctly parses paginated wallpaper data")
    void testListWallpapersSuccess() {
        String jsonResponse = """
            {
              "data": [
                {
                  "id": "12345",
                  "title": "Mountain Sunset",
                  "description": "Scenic mountains",
                  "url": "https://api.wallaza.com/images/12345.jpg",
                  "thumbnail_url": "https://api.wallaza.com/thumbnails/12345.jpg",
                  "category": "Nature",
                  "tags": ["mountain", "sunset"],
                  "resolution": "1920x1080",
                  "file_size": 1240000,
                  "downloads": 5420,
                  "favorites": 1235,
                  "author": {
                    "id": "3456",
                    "name": "NaturePhotos",
                    "profile_url": "https://wallaza.com/users/3456"
                  },
                  "created_at": "2023-01-15T10:30:00Z"
                }
              ],
              "meta": {
                "current_page": 1,
                "total_pages": 10,
                "total_results": 200,
                "per_page": 20
              },
              "links": {
                "first": "https://api.wallaza.com/v1/wallpapers?page=1",
                "next": "https://api.wallaza.com/v1/wallpapers?page=2"
              }
            }
            """;

        server.expect(requestTo("https://api.wallaza.com/v1/wallpapers?page=1&limit=20&category=Nature"))
                .andExpect(method(HttpMethod.GET))
                .andExpect(header(HttpHeaders.AUTHORIZATION, "Bearer " + API_KEY))
                .andRespond(withSuccess(jsonResponse, MediaType.APPLICATION_JSON));

        WallpaperListResponse response = client.listWallpapers(
                WallpaperListQuery.builder()
                        .page(1)
                        .limit(20)
                        .category("Nature")
                        .build()
        );

        assertThat(response).isNotNull();
        assertThat(response.data()).hasSize(1);

        Wallpaper wallpaper = response.data().get(0);
        assertThat(wallpaper.id()).isEqualTo("12345");
        assertThat(wallpaper.title()).isEqualTo("Mountain Sunset");
        assertThat(wallpaper.category()).isEqualTo("Nature");
        assertThat(wallpaper.resolution()).isEqualTo("1920x1080");
        assertThat(wallpaper.author()).isNotNull();
        assertThat(wallpaper.author().name()).isEqualTo("NaturePhotos");
        assertThat(response.meta().totalResults()).isEqualTo(200);

        server.verify();
    }

    @Test
    @DisplayName("searchWallpapers builds correct query parameters and decodes results")
    void testSearchWallpapersSuccess() {
        String jsonResponse = """
            {
              "data": [
                {
                  "id": "999",
                  "title": "Neon Cyberpunk Skyline",
                  "url": "https://api.wallaza.com/images/999.jpg",
                  "category": "Cyberpunk",
                  "resolution": "3840x2160"
                }
              ],
              "meta": {
                "current_page": 1,
                "total_pages": 1,
                "total_results": 1,
                "per_page": 20
              }
            }
            """;

        server.expect(requestTo("https://api.wallaza.com/v1/wallpapers/search?query=cyberpunk&resolution=3840x2160&page=1&limit=20"))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess(jsonResponse, MediaType.APPLICATION_JSON));

        WallpaperListResponse response = client.searchWallpapers(
                WallpaperSearchQuery.builder()
                        .query("cyberpunk")
                        .resolution("3840x2160")
                        .build()
        );

        assertThat(response.data()).hasSize(1);
        assertThat(response.data().get(0).title()).isEqualTo("Neon Cyberpunk Skyline");
        server.verify();
    }

    @Test
    @DisplayName("getWallpaper fetches single wallpaper item")
    void testGetWallpaperSuccess() {
        String jsonResponse = """
            {
              "id": "12345",
              "title": "Mountain Sunset",
              "url": "https://api.wallaza.com/images/12345.jpg",
              "resolution": "1920x1080"
            }
            """;

        server.expect(requestTo("https://api.wallaza.com/v1/wallpapers/12345"))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess(jsonResponse, MediaType.APPLICATION_JSON));

        Wallpaper wallpaper = client.getWallpaper("12345");
        assertThat(wallpaper).isNotNull();
        assertThat(wallpaper.id()).isEqualTo("12345");
        assertThat(wallpaper.title()).isEqualTo("Mountain Sunset");
        server.verify();
    }

    @Test
    @DisplayName("HTTP 401 Unauthorized maps to WallazaAuthenticationException")
    void testAuthenticationFailure() {
        String errorJson = """
            {
              "error": {
                "code": "unauthorized",
                "message": "No valid API key provided",
                "status": 401
              }
            }
            """;

        server.expect(requestTo("https://api.wallaza.com/v1/wallpapers?page=1&limit=20"))
                .andRespond(withUnauthorizedRequest().body(errorJson).contentType(MediaType.APPLICATION_JSON));

        assertThatThrownBy(() -> client.listWallpapers(1, 20, null))
                .isInstanceOf(WallazaAuthenticationException.class)
                .hasMessageContaining("No valid API key provided");

        server.verify();
    }

    @Test
    @DisplayName("HTTP 404 Resource Not Found maps to WallazaNotFoundException")
    void testNotFoundFailure() {
        String errorJson = """
            {
              "error": {
                "code": "resource_not_found",
                "message": "The requested wallpaper with ID 99999 could not be found",
                "status": 404
              }
            }
            """;

        server.expect(requestTo("https://api.wallaza.com/v1/wallpapers/99999"))
                .andRespond(withResourceNotFound().body(errorJson).contentType(MediaType.APPLICATION_JSON));

        assertThatThrownBy(() -> client.getWallpaper("99999"))
                .isInstanceOf(WallazaNotFoundException.class)
                .hasMessageContaining("could not be found");

        server.verify();
    }

    @Test
    @DisplayName("HTTP 429 Rate Limit Exceeded maps to WallazaRateLimitException with quota metrics")
    void testRateLimitFailure() {
        String errorJson = """
            {
              "error": {
                "code": "rate_limit_exceeded",
                "message": "You have exceeded the rate limit of 1000 requests per hour",
                "status": 429,
                "additional_info": {
                  "limit": 1000,
                  "remaining": 0,
                  "reset_at": 1620000000
                }
              }
            }
            """;

        server.expect(requestTo("https://api.wallaza.com/v1/wallpapers?page=1&limit=20"))
                .andRespond(withTooManyRequests().body(errorJson).contentType(MediaType.APPLICATION_JSON));

        assertThatThrownBy(() -> client.listWallpapers())
                .isInstanceOf(WallazaRateLimitException.class)
                .satisfies(ex -> {
                    WallazaRateLimitException rle = (WallazaRateLimitException) ex;
                    assertThat(rle.getLimit()).isEqualTo(1000L);
                    assertThat(rle.getRemaining()).isEqualTo(0L);
                    assertThat(rle.getResetAt()).isEqualTo(1620000000L);
                });

        server.verify();
    }

    @Test
    @DisplayName("HTTP 400 Validation Error maps to WallazaValidationException")
    void testValidationFailure() {
        String errorJson = """
            {
              "error": {
                "code": "validation_error",
                "message": "Invalid resolution format",
                "status": 400,
                "additional_info": {
                  "field": "resolution"
                }
              }
            }
            """;

        server.expect(requestTo("https://api.wallaza.com/v1/wallpapers/search?query=nature&resolution=bad_format&page=1&limit=20"))
                .andRespond(withBadRequest().body(errorJson).contentType(MediaType.APPLICATION_JSON));

        assertThatThrownBy(() -> client.searchWallpapers("nature", "bad_format"))
                .isInstanceOf(WallazaValidationException.class)
                .hasMessageContaining("Invalid resolution format");

        server.verify();
    }
}
