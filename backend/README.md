# Wallaza Service — Java Spring Boot API Wrapper & Client SDK

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.4.0-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-21%2B-blue.svg)](https://openjdk.org/)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](LICENSE)
[![OpenAPI](https://img.shields.io/badge/OpenAPI-3.0%20Swagger-green.svg)](http://localhost:8080/swagger-ui.html)

A unified, easily maintainable Java Spring Boot project that provides:
1. **REST API Proxy Gateway**: Exposes cached, rate-limit protected endpoints for discovering, searching, inspecting, and streaming wallpapers from the **[Wallaza API](https://github.com/LabsVia/wallaza)**.
2. **Built-in Java Client SDK**: High-level, type-safe client interface and models for calling Wallaza programmatically from Java code.

---

## 🏗️ Project Architecture (Single Unified Project)

Everything is consolidated into a single, clean project with one `pom.xml` for effortless maintenance and builds:

```
wallaza-service/
├── pom.xml                                   # Single parent-less POM (Spring Boot 3.4.0, Java 21)
├── mvnw / mvnw.cmd / .mvn/                   # Maven Wrapper (zero install required)
├── README.md                                 # Complete documentation
│
└── src/
    ├── main/
    │   ├── java/com/wallaza/
    │   │   ├── WallazaApplication.java       # Spring Boot main entrypoint
    │   │   │
    │   │   ├── client/                       # Client SDK (Interface, Impl & Models)
    │   │   │   ├── WallazaClient.java        # Interface (list, search, get, download)
    │   │   │   ├── WallazaClientBuilder.java # Standalone builder (for non-Spring code)
    │   │   │   ├── impl/WallazaClientImpl.java # Spring RestClient implementation
    │   │   │   ├── model/                    # Immutable records (Wallpaper, Author, Pagination)
    │   │   │   └── exception/                # Typed exceptions (401, 403, 404, 429, 400, 500)
    │   │   │
    │   │   ├── controller/                   # REST API Proxy Endpoints
    │   │   │   └── WallpaperController.java  # /api/v1/wallpapers endpoints with OpenAPI docs
    │   │   │
    │   │   ├── config/                       # Application Configuration
    │   │   │   ├── WallazaClientConfig.java  # Registers WallazaClient bean
    │   │   │   ├── WallazaProperties.java    # wallaza.* configuration properties
    │   │   │   ├── CacheConfig.java          # Caffeine 15-minute in-memory cache
    │   │   │   └── OpenApiConfig.java        # Swagger UI / OpenAPI 3.0 specs
    │   │   │
    │   │   └── exception/                    # Global Exception Handling
    │   │       └── GlobalExceptionHandler.java # Uniform Wallaza JSON error responses
    │   │
    │   └── resources/
    │       └── application.yml               # Application configuration
    │
    └── test/java/com/wallaza/
        ├── client/WallazaClientTest.java     # Unit tests with MockRestServiceServer
        └── controller/WallpaperControllerTest.java # WebMvcTest controller integration tests
```

---

## ⚡ Quickstart

### 1. Configure Wallaza API Key
Set your key as an environment variable:
```bash
export WALLAZA_API_KEY="your_api_key_here"
```
Or directly in [`src/main/resources/application.yml`](file:///Users/zml-mac-ranveerg-01/flutterProject/wallaza-service/src/main/resources/application.yml):
```yaml
wallaza:
  api-key: your_api_key_here
  base-url: https://api.wallaza.com/v1
  connect-timeout: 5s
  read-timeout: 15s
```

### 2. Run All Tests
```bash
cd /Users/zml-mac-ranveerg-01/flutterProject/wallaza-service
./mvnw clean test
```

### 3. Start the Server (Single Command)
```bash
./mvnw spring-boot:run
```
The application will boot on `http://localhost:8080`.

---

## 📖 REST API Endpoints & `curl` Examples

### 1. List Wallpapers (Cached)
```bash
curl -X GET "http://localhost:8080/api/v1/wallpapers?page=1&limit=20&category=Nature" \
     -H "Accept: application/json"
```

### 2. Search Wallpapers (Cached)
```bash
curl -X GET "http://localhost:8080/api/v1/wallpapers/search?query=cyberpunk&resolution=3840x2160&page=1&limit=20" \
     -H "Accept: application/json"
```

### 3. Get Wallpaper Details by ID (Cached)
```bash
curl -X GET "http://localhost:8080/api/v1/wallpapers/12345" \
     -H "Accept: application/json"
```

### 4. Direct Image Streaming / Download
```bash
curl -X GET "http://localhost:8080/api/v1/wallpapers/12345/download" \
     --output "wallpaper_12345.jpg"
```

---

## 💻 Using the Internal Client SDK

### In Spring Services
Inject `WallazaClient` anywhere in your code:
```java
@Service
public class WallpaperService {

    private final WallazaClient wallazaClient;

    public WallpaperService(WallazaClient wallazaClient) {
        this.wallazaClient = wallazaClient;
    }

    public List<Wallpaper> getWallpapers() {
        return wallazaClient.listWallpapers(1, 10, "Cyberpunk").data();
    }
}
```

### Standalone (Without Spring)
```java
WallazaClient client = WallazaClientBuilder.create()
        .apiKey("YOUR_API_KEY")
        .build();

WallpaperListResponse response = client.listWallpapers(1, 10, "Nature");
```

---

## 📑 Interactive Documentation (Swagger UI)

- **Swagger UI**: [http://localhost:8080/swagger-ui.html](http://localhost:8080/swagger-ui.html)
- **OpenAPI JSON**: [http://localhost:8080/v3/api-docs](http://localhost:8080/v3/api-docs)
