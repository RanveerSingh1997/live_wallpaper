package com.wallaza.client.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.Instant;
import java.util.List;

/**
 * Representation of a Wallaza Wallpaper entity.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record Wallpaper(
        @JsonProperty("id") String id,
        @JsonProperty("title") String title,
        @JsonProperty("description") String description,
        @JsonProperty("url") String url,
        @JsonProperty("thumbnail_url") String thumbnailUrl,
        @JsonProperty("category") String category,
        @JsonProperty("tags") List<String> tags,
        @JsonProperty("resolution") String resolution,
        @JsonProperty("file_size") Long fileSize,
        @JsonProperty("downloads") Long downloads,
        @JsonProperty("favorites") Long favorites,
        @JsonProperty("author") WallpaperAuthor author,
        @JsonProperty("created_at") Instant createdAt
) {
    public Wallpaper {
        tags = tags == null ? List.of() : List.copyOf(tags);
    }
}
