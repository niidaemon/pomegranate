FROM eclipse-temurin:21 AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

COPY pom.xml ./
RUN mvn dependency:go-offline -B

COPY src src
RUN mvn package -DskipTests -B

FROM eclipse-temurin:21-jre AS runtime

WORKDIR /app
COPY --from=builder /app/target/ ./target/

EXPOSE 8007
ENTRYPOINT ["sh", "-c", "java -jar target/*.jar"]
