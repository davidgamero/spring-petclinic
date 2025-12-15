# Dockerfile for Spring PetClinic
# Uses pre-built JAR approach for faster builds and to avoid network restrictions
# Build JAR first: ./mvnw package -DskipTests
#
# Compliant with organizational policy: Uses Microsoft Container Registry (MCR) base images

FROM mcr.microsoft.com/openjdk/jdk:17-mariner

WORKDIR /app

# Create non-root user for security
RUN groupadd -r spring && useradd -r -g spring spring

# Copy the pre-built JAR (build with: ./mvnw package -DskipTests)
COPY target/spring-petclinic-*.jar app.jar

# Change ownership to non-root user
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring:spring

# Expose the application port
EXPOSE 8080

# Set environment variables for Spring Boot
ENV SPRING_PROFILES_ACTIVE=default
ENV JAVA_OPTS=""

# Health check using Spring Boot Actuator (using wget as curl is not available in mariner)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
