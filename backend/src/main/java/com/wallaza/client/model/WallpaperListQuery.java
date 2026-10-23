package com.wallaza.client.model;

/**
 * Query criteria for listing wallpapers.
 */
public record WallpaperListQuery(
        Integer page,
        Integer limit,
        String category
) {
    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private Integer page = 1;
        private Integer limit = 20;
        private String category;

        public Builder page(Integer page) {
            this.page = page;
            return this;
        }

        public Builder limit(Integer limit) {
            this.limit = limit;
            return this;
        }

        public Builder category(String category) {
            this.category = category;
            return this;
        }

        public WallpaperListQuery build() {
            return new WallpaperListQuery(page, limit, category);
        }
    }
}
