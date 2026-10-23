package com.wallaza;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

/**
 * Main Spring Boot application entrypoint for the Wallaza API Proxy Service and Client.
 */
@SpringBootApplication
@EnableCaching
public class WallazaApplication {

    public static void main(String[] args) {
        SpringApplication.run(WallazaApplication.class, args);
    }
}
