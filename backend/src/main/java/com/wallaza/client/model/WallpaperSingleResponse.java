package com.wallaza.client.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Envelope for single wallpaper responses that wrap the payload under "data".
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record WallpaperSingleResponse(
        @JsonProperty("data") Wallpaper data
) {
}
