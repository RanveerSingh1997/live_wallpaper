package com.wallaza.client.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * Standard paginated collection envelope returned by Wallaza API.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record WallpaperListResponse(
        @JsonProperty("data") List<Wallpaper> data,
        @JsonProperty("meta") PaginationMeta meta,
        @JsonProperty("links") PaginationLinks links
) {
    public WallpaperListResponse {
        data = data == null ? List.of() : List.copyOf(data);
    }
}
