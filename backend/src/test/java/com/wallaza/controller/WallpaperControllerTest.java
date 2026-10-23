package com.wallaza.controller;

import com.wallaza.WallazaApplication;
import com.wallaza.client.WallazaClient;
import com.wallaza.client.exception.WallazaNotFoundException;
import com.wallaza.client.exception.WallazaRateLimitException;
import com.wallaza.client.model.*;
import com.wallaza.exception.GlobalExceptionHandler;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(controllers = WallpaperController.class)
@ContextConfiguration(classes = {WallazaApplication.class})
@Import(GlobalExceptionHandler.class)
class WallpaperControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private WallazaClient wallazaClient;

    @Test
    @DisplayName("GET /api/v1/wallpapers returns paginated wallpapers list")
    void testListWallpapers() throws Exception {
        Wallpaper sample = new Wallpaper(
                "w-101",
                "Aurora Borealis",
                "Northern lights in Norway",
                "https://api.wallaza.com/images/101.jpg",
                "https://api.wallaza.com/thumbnails/101.jpg",
                "Nature",
                List.of("aurora", "night"),
                "3840x2160",
                3500000L,
                1500L,
                820L,
                new WallpaperAuthor("a-1", "ArcticPhotos", "https://wallaza.com/users/a-1"),
                Instant.parse("2023-01-15T10:30:00Z")
        );

        WallpaperListResponse listResponse = new WallpaperListResponse(
                List.of(sample),
                new PaginationMeta(1, 5, 100L, 20),
                new PaginationLinks("first_link", null, "next_link", "last_link")
        );

        when(wallazaClient.listWallpapers(any(WallpaperListQuery.class))).thenReturn(listResponse);

        mockMvc.perform(get("/api/v1/wallpapers")
                        .param("page", "1")
                        .param("limit", "20")
                        .param("category", "Nature")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id").value("w-101"))
                .andExpect(jsonPath("$.data[0].title").value("Aurora Borealis"))
                .andExpect(jsonPath("$.data[0].category").value("Nature"))
                .andExpect(jsonPath("$.meta.total_results").value(100));
    }

    @Test
    @DisplayName("GET /api/v1/wallpapers/search queries Wallaza search endpoint")
    void testSearchWallpapers() throws Exception {
        Wallpaper sample = new Wallpaper(
                "w-102",
                "Cyberpunk Alley",
                "Neon lights in Tokyo alley",
                "https://api.wallaza.com/images/102.jpg",
                "https://api.wallaza.com/thumbnails/102.jpg",
                "Cyberpunk",
                List.of("cyber", "neon"),
                "1920x1080",
                2100000L,
                900L,
                430L,
                null,
                Instant.now()
        );

        WallpaperListResponse searchResponse = new WallpaperListResponse(
                List.of(sample),
                new PaginationMeta(1, 1, 1L, 20),
                null
        );

        when(wallazaClient.searchWallpapers(any(WallpaperSearchQuery.class))).thenReturn(searchResponse);

        mockMvc.perform(get("/api/v1/wallpapers/search")
                        .param("query", "cyberpunk")
                        .param("resolution", "1920x1080")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id").value("w-102"))
                .andExpect(jsonPath("$.data[0].title").value("Cyberpunk Alley"));
    }

    @Test
    @DisplayName("GET /api/v1/wallpapers/{id} returns single wallpaper")
    void testGetWallpaperById() throws Exception {
        Wallpaper sample = new Wallpaper(
                "w-103",
                "OLED Minimal Noir",
                "Pure black aesthetics",
                "https://api.wallaza.com/images/103.jpg",
                "https://api.wallaza.com/thumbnails/103.jpg",
                "Minimal",
                List.of("minimal", "oled"),
                "3840x2160",
                1200000L,
                2300L,
                1100L,
                null,
                Instant.now()
        );

        when(wallazaClient.getWallpaper("w-103")).thenReturn(sample);

        mockMvc.perform(get("/api/v1/wallpapers/w-103")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value("w-103"))
                .andExpect(jsonPath("$.title").value("OLED Minimal Noir"));
    }

    @Test
    @DisplayName("GET /api/v1/wallpapers/{id}/download streams binary image")
    void testDownloadWallpaper() throws Exception {
        byte[] fakeImageBytes = new byte[]{ (byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0 };
        when(wallazaClient.downloadWallpaperBytes("w-104")).thenReturn(fakeImageBytes);

        mockMvc.perform(get("/api/v1/wallpapers/w-104/download"))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Disposition", "inline; filename=\"w-104.jpg\""))
                .andExpect(content().contentType(MediaType.IMAGE_JPEG))
                .andExpect(content().bytes(fakeImageBytes));
    }

    @Test
    @DisplayName("Handles WallazaNotFoundException with standard 404 error envelope")
    void testNotFoundHandling() throws Exception {
        when(wallazaClient.getWallpaper("missing_id"))
                .thenThrow(new WallazaNotFoundException("Wallpaper not found", "resource_not_found", Map.of()));

        mockMvc.perform(get("/api/v1/wallpapers/missing_id")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error.code").value("resource_not_found"))
                .andExpect(jsonPath("$.error.status").value(404));
    }

    @Test
    @DisplayName("Handles WallazaRateLimitException with 429 status and X-RateLimit-Reset header")
    void testRateLimitHandling() throws Exception {
        when(wallazaClient.listWallpapers(any(WallpaperListQuery.class)))
                .thenThrow(new WallazaRateLimitException(
                        "Rate limit exceeded",
                        "rate_limit_exceeded",
                        Map.of("limit", 1000L, "remaining", 0L, "reset_at", 1700000000L)
                ));

        mockMvc.perform(get("/api/v1/wallpapers")
                        .accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isTooManyRequests())
                .andExpect(header().string("X-RateLimit-Reset", "1700000000"))
                .andExpect(jsonPath("$.error.code").value("rate_limit_exceeded"))
                .andExpect(jsonPath("$.error.status").value(429));
    }
}
