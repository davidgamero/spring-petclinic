# Docker Guide for Spring PetClinic

This guide explains how to build and run the Spring PetClinic application using Docker.

## Quick Start

The simplest way to run PetClinic with Docker:

```bash
# 1. Build the application JAR
./mvnw package -DskipTests

# 2. Build the Docker image
docker build -f Dockerfile.simple -t spring-petclinic:latest .

# 3. Run the container
docker run -d -p 8080:8080 --name petclinic spring-petclinic:latest

# 4. Access the application
# Open http://localhost:8080 in your browser
```

## Available Dockerfiles

### Dockerfile.simple (Recommended)
- **Use case**: When you build the JAR locally first
- **Advantages**: 
  - Fast build time
  - Avoids network/SSL issues in certain Docker environments
  - Works well with CI/CD pipelines where build happens separately
- **Build process**:
  ```bash
  ./mvnw package -DskipTests
  docker build -f Dockerfile.simple -t spring-petclinic:latest .
  ```

### Dockerfile (Multi-stage Build)
- **Use case**: When you want Docker to build everything
- **Advantages**:
  - Self-contained build process
  - Smaller final image (multi-stage build)
  - No local Maven installation required
- **Note**: May encounter SSL certificate issues in some Docker environments
- **Build process**:
  ```bash
  docker build -t spring-petclinic:latest .
  ```

## Running the Container

### Basic Run
```bash
docker run -d -p 8080:8080 --name petclinic spring-petclinic:latest
```

### With Environment Variables
```bash
docker run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=mysql \
  -e MYSQL_URL=jdbc:mysql://host.docker.internal:3306/petclinic \
  --name petclinic \
  spring-petclinic:latest
```

### With MySQL Database
```bash
# Start MySQL
docker run -d \
  --name petclinic-mysql \
  -e MYSQL_ROOT_PASSWORD=petclinic \
  -e MYSQL_DATABASE=petclinic \
  -e MYSQL_USER=petclinic \
  -e MYSQL_PASSWORD=petclinic \
  -p 3306:3306 \
  mysql:9.5

# Start PetClinic
docker run -d -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=mysql \
  -e MYSQL_URL=jdbc:mysql://host.docker.internal:3306/petclinic \
  --name petclinic \
  spring-petclinic:latest
```

### Using Docker Compose
```bash
# Start both the database and application
docker compose up
```

## Health Check

The Docker image includes a health check that monitors the application's status:

```bash
# Check container health
docker ps

# View health check logs
docker inspect petclinic | grep -A 10 Health
```

## Security Features

The Docker image follows security best practices:

- ✅ Runs as non-root user (`spring:spring`)
- ✅ Uses official Eclipse Temurin JRE (minimal attack surface)
- ✅ Multi-stage build (when using Dockerfile)
- ✅ Health check enabled
- ✅ Minimal dependencies in runtime image

## Image Details

- **Base Image**: `eclipse-temurin:17-jre-jammy`
- **User**: `spring` (non-root)
- **Port**: `8080`
- **Health Check**: `/actuator/health` endpoint
- **Image Size**: ~350 MB (runtime image)

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs petclinic

# Check if port is already in use
lsof -i :8080
```

### SSL certificate errors during build
If you encounter SSL certificate errors when using the multi-stage Dockerfile, use `Dockerfile.simple` instead:
```bash
./mvnw package -DskipTests
docker build -f Dockerfile.simple -t spring-petclinic:latest .
```

### Application health check failing
The application may take 30-40 seconds to fully start. Wait a moment and check again:
```bash
curl http://localhost:8080/actuator/health
```

## Useful Commands

```bash
# View running containers
docker ps

# Stop the container
docker stop petclinic

# Start the container
docker start petclinic

# Remove the container
docker rm petclinic

# View logs (follow)
docker logs -f petclinic

# Execute commands in container
docker exec -it petclinic /bin/bash

# Remove the image
docker rmi spring-petclinic:latest
```

## Production Considerations

For production deployments:

1. **Use specific tags** instead of `latest`:
   ```bash
   docker build -f Dockerfile.simple -t spring-petclinic:1.0.0 .
   ```

2. **Set resource limits**:
   ```bash
   docker run -d -p 8080:8080 \
     --memory="512m" \
     --cpus="1.0" \
     --name petclinic \
     spring-petclinic:latest
   ```

3. **Use external database** (MySQL or PostgreSQL) instead of in-memory H2

4. **Configure proper logging**:
   ```bash
   docker run -d -p 8080:8080 \
     -e LOGGING_LEVEL_ROOT=INFO \
     -v /var/log/petclinic:/logs \
     --name petclinic \
     spring-petclinic:latest
   ```

5. **Enable JVM monitoring** and adjust heap settings:
   ```bash
   docker run -d -p 8080:8080 \
     -e JAVA_OPTS="-Xmx256m -Xms256m" \
     --name petclinic \
     spring-petclinic:latest
   ```

## Alternative: Spring Boot Build Plugin

Spring Boot also provides its own image building capability:

```bash
./mvnw spring-boot:build-image
docker run -p 8080:8080 spring-petclinic:4.0.0-SNAPSHOT
```

This creates a layered image with Cloud Native Buildpacks, which can be beneficial for certain deployment scenarios.
