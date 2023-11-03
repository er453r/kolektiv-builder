FROM maven:3.6.3-openjdk-17 as build

# prepare runtime
WORKDIR /build
RUN jlink --add-modules ALL-MODULE-PATH --output runtime --no-header-files --no-man-pages --compress=2 --strip-debug

# build all dependencies for offline use and cache them
COPY pom.xml ./
RUN mvn dependency:go-offline

# copy all other files
COPY src ./src

# build
RUN mvn package

FROM debian:bookworm-slim
RUN useradd -m ives
USER ives
WORKDIR /home/ives
COPY --from=build --chown=ives:ives /build/runtime runtime
COPY --from=build --chown=ives:ives /build/target/*.jar ./builder-server.jar
ENTRYPOINT runtime/bin/java -jar imq-server.jar & wait
