package com.wallaza.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.cache.CacheManager;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;
import java.util.List;

/**
 * Caffeine in-memory cache configuration for wallpaper queries to optimize latency and respect rate limits.
 */
@Configuration
public class CacheConfig {

    public static final String CACHE_WALLPAPERS_LIST = "wallpapers-list";
    public static final String CACHE_WALLPAPERS_SEARCH = "wallpapers-search";
    public static final String CACHE_WALLPAPERS_DETAIL = "wallpapers-detail";

    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();
        cacheManager.setCacheNames(List.of(
                CACHE_WALLPAPERS_LIST,
                CACHE_WALLPAPERS_SEARCH,
                CACHE_WALLPAPERS_DETAIL
        ));
        cacheManager.setCaffeine(Caffeine.newBuilder()
                .initialCapacity(100)
                .maximumSize(5000)
                .expireAfterWrite(Duration.ofMinutes(15))
                .recordStats());
        return cacheManager;
    }
}
