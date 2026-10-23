package com.wallaza.client.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Pagination metadata provided in Wallaza collection responses.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record PaginationMeta(
        @JsonProperty("current_page") Integer currentPage,
        @JsonProperty("total_pages") Integer totalPages,
        @JsonProperty("total_results") Long totalResults,
        @JsonProperty("per_page") Integer perPage
) {
}
