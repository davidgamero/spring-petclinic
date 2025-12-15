# Dockerfile for Spring PetClinic
# Build the JAR first with: ./mvnw package -DskipTests -B
# Then build the image with: docker build -t spring-petclinic .

FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Create a non-root user for security
RUN groupadd --system spring && useradd --system --gid spring spring

# Copy the pre-built JAR file
COPY target/*.jar app.jar

# Change ownership to non-root user
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring:spring

# Expose the application port
EXPOSE 8080

# Run the application with optimized JVM settings
ENTRYPOINT ["java", "-jar", "app.jar"]
