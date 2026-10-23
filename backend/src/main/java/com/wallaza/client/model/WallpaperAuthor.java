package com.wallaza.client.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Information regarding the wallpaper creator/author.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record WallpaperAuthor(
        @JsonProperty("id") String id,
        @JsonProperty("name") String name,
        @JsonProperty("profile_url") String profileUrl
) {
}
