# ==============================================================================
# Wallaza Service — Multi-Stage Production Dockerfile (Spring Boot 3.4 / Java 21)
# ==============================================================================

# ------------------------------------------------------------------------------
# Stage 1: Build & Package (JDK)
# ------------------------------------------------------------------------------
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /build

# Copy Maven Wrapper & POM first for layer-cached dependency downloads
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x ./mvnw && ./mvnw dependency:go-offline -B

# Copy application source code
COPY src/ src/

# Package executable JAR (skipping tests since tests run in CI pipeline)
RUN ./mvnw clean package -DskipTests -B

# ------------------------------------------------------------------------------
# Stage 2: Minimal Hardened Runtime (JRE)
# ------------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine AS runtime

LABEL maintainer="Wallora Core Engineering" \
      service="wallaza-service" \
      version="1.0.0" \
      description="Production container for Wallaza API Wrapper & Client SDK"

# Install curl for healthchecks and tzdata for timezone accuracy
RUN apk add --no-cache curl tzdata && \
    addgroup -S spring && adduser -S spring -G spring

WORKDIR /app

# Copy JAR artifact from builder stage
COPY --from=builder --chown=spring:spring /build/target/*.jar /app/app.jar

# Drop root privileges
USER spring:spring

# Expose default HTTP application port
EXPOSE 8080

# Configure production-ready containerized JVM flags
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -Djava.security.egd=file:/dev/./urandom"

# Container Healthcheck targeting Spring Boot Actuator
HEALTHCHECK --interval=15s --timeout=3s --start-period=20s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Launch application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
