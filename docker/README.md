# Simulator Docker Image

The image contains the simulator, its Python dependencies, protocol definitions,
and the package's `config.toml` at build time. Running it requires only Docker
and an accessible MQTT broker, not the source package or ROS. The graphical
commander/visualizer is not included.

## Build

From the package root:

```bash
bash docker/build_docker_image.sh
```

An optional first argument sets the image name and tag:

```bash
bash docker/build_docker_image.sh vda5050-robot-simulator:1.0
```

Alternatively:

```bash
docker build -f docker/Dockerfile -t vda5050-robot-simulator:latest .
```

Set `config.toml` to the desired broker and robot settings before building to
bake them into the image. Rebuild after changing it, or use the optional config
override below.

## Run

Docker Compose launches the prebuilt image; it does not need the source package
or build the image. Docker Compose v2 and an accessible MQTT broker are required.

Set the image tag in `services.simulator.image` and the host config path in
`services.simulator.volumes[0].source` directly in `docker/compose.yaml`.

The supplied `source: ../config.toml` works with the package's existing config.
Relative paths resolve from the `compose.yaml` directory. On another machine,
change `source` to the actual external config path, for example
`source: /absolute/path/to/config.toml`.

Compose mounts that host file read-only at `/config/config.toml`. The container's
`VDA5050_CONFIG`, defined in the Compose `environment` section, is set to
`/config/config.toml`; the host path is not passed to Python. The file must
already exist and be readable by UID 10001. Missing files cause startup to fail
instead of creating a directory.

From the package root:

```bash
cd docker
docker compose config
docker compose up -d
docker compose logs -f simulator
```

Host networking lets the simulator reach an MQTT broker on the Linux host at
`localhost:1883`. No ports need to be published: the simulator is an MQTT client.
An external broker is also supported by changing `mqtt_broker.host` in the TOML
file. The image is not pulled automatically; build it locally or load it first.

After editing the TOML file, restart the simulator to reload it. After changing
`compose.yaml`, run `docker compose up -d` to apply the new mount or image tag.

```bash
docker compose restart simulator
docker compose down
```

Outside Docker, `python main.py --config /absolute/path/to/config.toml` remains
supported. `--config` takes precedence over `VDA5050_CONFIG`; without either,
Python uses the working directory's `config.toml`.

## Transfer Without the Package

On the build machine:

```bash
docker save -o vda5050-robot-simulator.tar vda5050-robot-simulator:latest
```

Transfer the archive, `compose.yaml`, and the external config file to another
machine. No Python source package is needed. Update the volume's `source` in
`compose.yaml` with that machine's config path, then run from the directory
containing `compose.yaml`:

```bash
docker load -i vda5050-robot-simulator.tar
docker compose up -d
```

The destination needs a compatible CPU architecture and an MQTT broker reachable
at the address configured in the external TOML file.