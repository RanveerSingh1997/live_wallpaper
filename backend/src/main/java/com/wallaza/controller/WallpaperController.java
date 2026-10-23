package com.wallaza.controller;

import com.wallaza.client.WallazaClient;
import com.wallaza.client.model.Wallpaper;
import com.wallaza.client.model.WallpaperListQuery;
import com.wallaza.client.model.WallpaperListResponse;
import com.wallaza.client.model.WallpaperSearchQuery;
import com.wallaza.config.CacheConfig;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Validated
@RestController
@RequestMapping("/api/v1/wallpapers")
@Tag(name = "Wallpapers", description = "Endpoints for discovering, searching, inspecting, and streaming Wallaza wallpapers")
public class WallpaperController {

    private final WallazaClient wallazaClient;

    public WallpaperController(WallazaClient wallazaClient) {
        this.wallazaClient = wallazaClient;
    }

    @GetMapping
    @Operation(summary = "List wallpapers", description = "Retrieves a paginated list of wallpapers with optional category filtering. Cached for 15 minutes.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Wallpapers retrieved successfully",
                    content = @Content(schema = @Schema(implementation = WallpaperListResponse.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - Wallaza API key invalid"),
            @ApiResponse(responseCode = "429", description = "Rate limit exceeded")
    })
    @Cacheable(value = CacheConfig.CACHE_WALLPAPERS_LIST, key = "{#page, #limit, #category}")
    public ResponseEntity<WallpaperListResponse> listWallpapers(
            @Parameter(description = "Page number (1-based)") @RequestParam(defaultValue = "1") @Min(1) Integer page,
            @Parameter(description = "Number of items per page (max 100)") @RequestParam(defaultValue = "20") @Min(1) @Max(100) Integer limit,
            @Parameter(description = "Optional category filter (e.g. Nature, Urban, Abstract)") @RequestParam(required = false) String category
    ) {
        WallpaperListQuery query = WallpaperListQuery.builder()
                .page(page)
                .limit(limit)
                .category(category)
                .build();

        WallpaperListResponse response = wallazaClient.listWallpapers(query);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/search")
    @Operation(summary = "Search wallpapers", description = "Searches wallpapers matching keywords and optional resolution filters. Cached for 15 minutes.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Search completed successfully",
                    content = @Content(schema = @Schema(implementation = WallpaperListResponse.class))),
            @ApiResponse(responseCode = "400", description = "Invalid search query parameter")
    })
    @Cacheable(value = CacheConfig.CACHE_WALLPAPERS_SEARCH, key = "{#query, #resolution, #page, #limit}")
    public ResponseEntity<WallpaperListResponse> searchWallpapers(
            @Parameter(description = "Keyword search query (e.g. mountain, cyber, neon)") @RequestParam @NotBlank String query,
            @Parameter(description = "Optional resolution filter (e.g. 1920x1080, 3840x2160)") @RequestParam(required = false) String resolution,
            @Parameter(description = "Page number") @RequestParam(defaultValue = "1") @Min(1) Integer page,
            @Parameter(description = "Results limit (max 100)") @RequestParam(defaultValue = "20") @Min(1) @Max(100) Integer limit
    ) {
        WallpaperSearchQuery searchQuery = WallpaperSearchQuery.builder()
                .query(query)
                .resolution(resolution)
                .page(page)
                .limit(limit)
                .build();

        WallpaperListResponse response = wallazaClient.searchWallpapers(searchQuery);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get wallpaper by ID", description = "Fetches comprehensive details and resolution specs for a single wallpaper. Cached for 15 minutes.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Wallpaper found",
                    content = @Content(schema = @Schema(implementation = Wallpaper.class))),
            @ApiResponse(responseCode = "404", description = "Wallpaper not found")
    })
    @Cacheable(value = CacheConfig.CACHE_WALLPAPERS_DETAIL, key = "#id")
    public ResponseEntity<Wallpaper> getWallpaper(
            @Parameter(description = "Unique wallpaper ID") @PathVariable String id
    ) {
        Wallpaper wallpaper = wallazaClient.getWallpaper(id);
        return ResponseEntity.ok(wallpaper);
    }

    @GetMapping(value = "/{id}/download", produces = {MediaType.IMAGE_JPEG_VALUE, MediaType.APPLICATION_OCTET_STREAM_VALUE})
    @Operation(summary = "Download / stream wallpaper image", description = "Directly downloads and streams the raw high-resolution wallpaper image binary.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Wallpaper image binary stream",
                    content = @Content(mediaType = MediaType.IMAGE_JPEG_VALUE)),
            @ApiResponse(responseCode = "404", description = "Wallpaper image not found")
    })
    public ResponseEntity<byte[]> downloadWallpaper(
            @Parameter(description = "Unique wallpaper ID") @PathVariable String id
    ) {
        byte[] imageBytes = wallazaClient.downloadWallpaperBytes(id);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + id + ".jpg\"")
                .contentType(MediaType.IMAGE_JPEG)
                .body(imageBytes);
    }
}
