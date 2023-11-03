FROM maven:3.6.3-openjdk-17 as build

# prepare runtime
WORKDIR /build

# build all dependencies for offline use and cache them
COPY pom.xml ./
RUN mvn dependency:go-offline

# copy all other files
COPY src ./src

# build
RUN mvn package

# build jre
RUN jar xf target/*.jar
RUN jdeps --ignore-missing-deps -quiet --recursive --multi-release 17 --print-module-deps --class-path 'BOOT-INF/lib/*' target/*.jar > deps.info
RUN jlink --add-modules $(cat deps.info) --strip-debug --compress 2 --no-header-files --no-man-pages --output runtime

FROM debian:bookworm-slim
RUN useradd -m kolektiv
USER kolektiv
WORKDIR /home/kolektiv
COPY --from=build --chown=kolektiv:kolektiv /build/runtime runtime
COPY --from=build --chown=kolektiv:kolektiv /build/target/*.jar ./builder-server.jar
ENTRYPOINT runtime/bin/java -jar builder-server.jar & wait
