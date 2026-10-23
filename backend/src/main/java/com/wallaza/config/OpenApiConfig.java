package com.wallaza.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * OpenAPI 3.0 / Swagger documentation configuration.
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI wallazaOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Wallaza Wallpaper API Proxy Service")
                        .description("High-performance Java Spring Boot wrapper & gateway for the Wallaza Wallpaper API with built-in caching, error translation, and direct image streaming.")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Wallaza API Support")
                                .url("https://www.wallaza.com/api-reference/")
                                .email("info@wallaza.com"))
                        .license(new License()
                                .name("MIT License")
                                .url("https://opensource.org/licenses/MIT")))
                .servers(List.of(
                        new Server().url("/").description("Current Server Gateway")
                ));
    }
}
