package com.wallaza.client;

import com.wallaza.client.model.Wallpaper;
import com.wallaza.client.model.WallpaperListQuery;
import com.wallaza.client.model.WallpaperListResponse;
import com.wallaza.client.model.WallpaperSearchQuery;
import java.io.InputStream;

/**
 * Java client interface for interacting with the Wallaza Wallpaper API.
 * 
 * @see <a href="https://www.wallaza.com/api-reference/">Wallaza API Documentation</a>
 */
public interface WallazaClient {

    /**
     * Lists wallpapers with pagination and optional category filtering.
     *
     * @param query pagination and filter parameters
     * @return paginated list of wallpapers
     */
    WallpaperListResponse listWallpapers(WallpaperListQuery query);

    /**
     * Convenience method to list wallpapers.
     *
     * @param page page number (1-based)
     * @param limit max results per page (1 to 100)
     * @param category optional category name (e.g. "Nature", "Urban")
     * @return paginated list of wallpapers
     */
    default WallpaperListResponse listWallpapers(Integer page, Integer limit, String category) {
        return listWallpapers(new WallpaperListQuery(page, limit, category));
    }

    /**
     * Lists default first page of wallpapers.
     *
     * @return paginated list of wallpapers
     */
    default WallpaperListResponse listWallpapers() {
        return listWallpapers(1, 20, null);
    }

    /**
     * Searches wallpapers using keyword queries, optional resolution constraints, and pagination.
     *
     * @param query search criteria
     * @return matching wallpapers
     */
    WallpaperListResponse searchWallpapers(WallpaperSearchQuery query);

    /**
     * Convenience search method.
     *
     * @param query search keyword
     * @param resolution optional resolution filter (e.g. "1920x1080", "3840x2160")
     * @return matching wallpapers
     */
    default WallpaperListResponse searchWallpapers(String query, String resolution) {
        return searchWallpapers(new WallpaperSearchQuery(query, resolution, 1, 20));
    }

    /**
     * Fetches detailed metadata for a specific wallpaper by its unique ID.
     *
     * @param wallpaperId unique wallpaper identifier
     * @return wallpaper details
     */
    Wallpaper getWallpaper(String wallpaperId);

    /**
     * Downloads the binary image data for a given wallpaper.
     *
     * @param wallpaperId unique wallpaper identifier
     * @return raw image bytes
     */
    byte[] downloadWallpaperBytes(String wallpaperId);

    /**
     * Opens an InputStream to stream the wallpaper image content directly.
     *
     * @param wallpaperId unique wallpaper identifier
     * @return input stream of binary image data
     */
    InputStream downloadWallpaperStream(String wallpaperId);
}
