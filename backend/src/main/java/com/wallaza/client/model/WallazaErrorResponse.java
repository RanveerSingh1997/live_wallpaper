package com.wallaza.client.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.Map;

/**
 * Error payload returned by Wallaza API during failure scenarios.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record WallazaErrorResponse(
        @JsonProperty("error") ErrorDetail error
) {
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ErrorDetail(
            @JsonProperty("code") String code,
            @JsonProperty("message") String message,
            @JsonProperty("status") Integer status,
            @JsonProperty("additional_info") Map<String, Object> additionalInfo
    ) {
    }
}
