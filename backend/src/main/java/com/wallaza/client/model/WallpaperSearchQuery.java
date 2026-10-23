package com.wallaza.client.model;

/**
 * Query criteria for searching wallpapers by keyword, resolution, and pagination.
 */
public record WallpaperSearchQuery(
        String query,
        String resolution,
        Integer page,
        Integer limit
) {
    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String query;
        private String resolution;
        private Integer page = 1;
        private Integer limit = 20;

        public Builder query(String query) {
            this.query = query;
            return this;
        }

        public Builder resolution(String resolution) {
            this.resolution = resolution;
            return this;
        }

        public Builder page(Integer page) {
            this.page = page;
            return this;
        }

        public Builder limit(Integer limit) {
            this.limit = limit;
            return this;
        }

        public WallpaperSearchQuery build() {
            if (query == null || query.isBlank()) {
                throw new IllegalArgumentException("Search query must not be blank");
            }
            return new WallpaperSearchQuery(query, resolution, page, limit);
        }
    }
}
