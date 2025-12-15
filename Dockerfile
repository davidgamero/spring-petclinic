# Multi-stage build for Spring PetClinic
# Note: If you encounter SSL certificate issues during Docker build in certain environments,
# you can build the JAR locally first with './mvnw package -DskipTests' and use
# the runtime-only stage below.

# Stage 1: Build the application
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy pom.xml and download dependencies (layer caching optimization)
COPY pom.xml ./
RUN mvn dependency:go-offline -B || true

# Copy source code
COPY src ./src

# Build the application
RUN mvn package -DskipTests -B

# Stage 2: Runtime image
FROM eclipse-temurin:17-jre-jammy

# Create non-root user for security
RUN groupadd -r spring && useradd -r -g spring spring

WORKDIR /app

# Copy the built artifact from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Change ownership to non-root user
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring:spring

# Expose the application port
EXPOSE 8080

# Health check using wget (included in base image)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
