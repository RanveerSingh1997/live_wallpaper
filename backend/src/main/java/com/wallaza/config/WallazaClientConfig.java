package com.wallaza.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wallaza.client.WallazaClient;
import com.wallaza.client.impl.WallazaClientImpl;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

/**
 * Spring configuration providing the {@link WallazaClient} bean.
 */
@Configuration
@EnableConfigurationProperties(WallazaProperties.class)
public class WallazaClientConfig {

    @Bean
    @ConditionalOnMissingBean(WallazaClient.class)
    public WallazaClient wallazaClient(WallazaProperties properties, ObjectMapper objectMapper) {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        if (properties.getConnectTimeout() != null) {
            requestFactory.setConnectTimeout((int) properties.getConnectTimeout().toMillis());
        }
        if (properties.getReadTimeout() != null) {
            requestFactory.setReadTimeout((int) properties.getReadTimeout().toMillis());
        }

        RestClient.Builder restClientBuilder = RestClient.builder()
                .requestFactory(requestFactory);

        return new WallazaClientImpl(
                properties.getApiKey(),
                properties.getBaseUrl(),
                objectMapper,
                restClientBuilder
        );
    }
}
