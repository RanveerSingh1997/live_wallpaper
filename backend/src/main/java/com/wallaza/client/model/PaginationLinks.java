package com.wallaza.client.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Hypermedia navigation links for paginated Wallaza queries.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record PaginationLinks(
        @JsonProperty("first") String first,
        @JsonProperty("prev") String prev,
        @JsonProperty("next") String next,
        @JsonProperty("last") String last
) {
}
