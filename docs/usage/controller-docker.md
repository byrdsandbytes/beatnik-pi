# Controller Docker Setup

Source: [byrdsandbytes/beatnik-controller](https://github.com/byrdsandbytes/beatnik-controller)

Beatnik Controller is a web-based remote control for your [Beatnik Pi](https://github.com/byrdsandbytes/beatnik-pi) or [Snapcast](https://github.com/badaix/snapcast) multi-room audio server. It allows you to easily manage and control audio streams from any device with a web browser. The application can also be compiled for Android and iOS and is available in the App- & Play Store.

See [Using the Beatnik Controller](./controller.md) for the features and screenshots.

::: tip Already included in Beatnik OS
The Beatnik Controller is pre-installed in [Beatnik OS](../software/flashing.md), so you don't need to set it up with Docker. Just open `http://<your-hostname>.local` in a browser. This guide is for other setups, such as the shell script or a manual installation.
:::

## Prerequisites

To run Beatnik Controller, you will need:

- A running Snapcast server on your network. This application is compatible with the standard [Snapcast server](https://github.com/badaix/snapcast). For a detailed installation guide for a Raspberry Pi based setup, we recommend [beatnik-pi](https://github.com/byrdsandbytes/beatnik-pi).
- [Docker](https://www.docker.com/get-started) and [Docker Compose](https://docs.docker.com/compose/install/).

## Installation

There are two ways to get Beatnik Controller running:

1. **Run with Docker (Recommended):** This is the easiest way to get started. It uses the pre-built Docker image from our registry and requires no local setup.
2. **Build from Source:** This is for developers who want to modify the code or contribute to the project.

## Method 1: Run with Docker (Recommended)

This method uses Docker to run the application without needing to build it yourself.

### 1. Get the Code

Clone this repository to your local machine:

```bash
git clone https://github.com/byrdsandbytes/beatnik-controller.git
cd beatnik-controller
```

### 2. Configure the Beatnik Pi or Snapcast Server (Optional)

By default, the application will try to connect to a Snapcast server at `beatnik-server.local`. If your server is at a different address, you can configure it in the in-app settings once the application is running.

### 3. Run with Docker

You can run the application using Docker Compose:

```bash
docker compose up -d
```

This will pull the latest Docker image and start the application in the background.

### 4. Access the Application

Open your web browser and navigate to `http://your-hostname.local`. You should now see the Beatnik Controller interface.

### 5. Updating

To update Beatnik Controller to the latest version, run the following commands in your cloned repository folder:

```bash
git pull
docker compose pull
docker compose up -d
```

### 6. Using a Specific Version

By default, the `docker-compose.yml` configuration uses the `latest` Docker image. The automated release pipeline also packages version-specific images when a new release is tagged.

If you prefer to install, use, or update to a specific locked version instead of `latest`, you can edit the `docker-compose.yml` file and replace `latest` with the desired version tag (for example, `v0.5.6`):

```yaml
services:
  beatnik:
    image: ghcr.io/byrdsandbytes/beatnik-controller:v0.5.6
```

Then pull the specific image and recreate the container to apply the version:

```bash
docker compose pull
docker compose up -d
```

## Method 2: Build from Source (for Developers)

This method is for developers who want to modify the code or contribute to the project.

### 1. Get the Code

Clone this repository to your local machine:

```bash
git clone https://github.com/byrdsandbytes/beatnik-controller.git
cd beatnik-controller
```

### 2. Configure the Beatnik Pi or Snapcast Server (Optional)

By default, the application will try to connect to a Snapcast server at `beatnik-server.local`. If your server is at a different address, you can edit `src/environments/environment.ts` and change `snapcastServerUrl` to your server's hostname or IP address.

### 3. Build and Run

If you want to build the Docker image from the source code, you can use the provided `docker-compose.build.yml` file. This is useful for testing local changes in a containerized environment.

```bash
docker compose -f docker-compose.build.yml up -d --build
```

This command builds the image and runs it locally. The application will be available at `http://localhost:8181`.

## Contributing

We welcome contributions! If you'd like to help improve Beatnik Controller, please see the [CONTRIBUTING.md](https://github.com/byrdsandbytes/beatnik-controller/blob/master/CONTRIBUTING.md) file for more information on how to get started. For details on the automated build pipeline, see [BUILD_PIPELINE.md](https://github.com/byrdsandbytes/beatnik-controller/blob/master/docs/BUILD_PIPELINE.md).

## License

This project is licensed under the AGPL v3 License - see the [LICENSE](https://github.com/byrdsandbytes/beatnik-controller/blob/master/LICENSE) file for details.
