package com.wallaza.client;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wallaza.client.impl.WallazaClientImpl;
import org.springframework.web.client.RestClient;

/**
 * Fluent builder for creating {@link WallazaClient} instances in standalone Java applications.
 */
public class WallazaClientBuilder {

    private String apiKey;
    private String baseUrl = "https://api.wallaza.com/v1";
    private ObjectMapper objectMapper;
    private RestClient.Builder restClientBuilder;

    public static WallazaClientBuilder create() {
        return new WallazaClientBuilder();
    }

    public WallazaClientBuilder apiKey(String apiKey) {
        this.apiKey = apiKey;
        return this;
    }

    public WallazaClientBuilder baseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
        return this;
    }

    public WallazaClientBuilder objectMapper(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        return this;
    }

    public WallazaClientBuilder restClientBuilder(RestClient.Builder restClientBuilder) {
        this.restClientBuilder = restClientBuilder;
        return this;
    }

    public WallazaClient build() {
        return new WallazaClientImpl(apiKey, baseUrl, objectMapper, restClientBuilder);
    }
}
