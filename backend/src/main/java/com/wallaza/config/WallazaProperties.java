package com.wallaza.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

/**
 * Configuration properties for the Wallaza API client.
 */
@ConfigurationProperties(prefix = "wallaza")
public class WallazaProperties {

    /**
     * Whether the Wallaza client is enabled.
     */
    private boolean enabled = true;

    /**
     * Secret API Key obtained from https://www.wallaza.com/api-reference/
     */
    private String apiKey;

    /**
     * Base URL for the Wallaza REST API.
     */
    private String baseUrl = "https://api.wallaza.com/v1";

    /**
     * Connection timeout for outgoing HTTP requests.
     */
    private Duration connectTimeout = Duration.ofSeconds(5);

    /**
     * Read timeout for outgoing HTTP responses.
     */
    private Duration readTimeout = Duration.ofSeconds(15);

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public Duration getConnectTimeout() {
        return connectTimeout;
    }

    public void setConnectTimeout(Duration connectTimeout) {
        this.connectTimeout = connectTimeout;
    }

    public Duration getReadTimeout() {
        return readTimeout;
    }

    public void setReadTimeout(Duration readTimeout) {
        this.readTimeout = readTimeout;
    }
}
