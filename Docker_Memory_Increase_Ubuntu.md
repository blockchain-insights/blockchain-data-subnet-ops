
# Increasing Docker Memory in Ubuntu

Increasing the memory allocation for Docker under Ubuntu involves adjusting the Docker daemon settings. Here's a step-by-step guide:

## 1. Access Docker Daemon Configuration
The Docker daemon settings are typically found in a JSON configuration file. This file might not exist by default and might need to be created.

### Check for Existing Configuration:
1. Open your terminal.
2. Check if the configuration file exists at `/etc/docker/daemon.json` using the command `ls /etc/docker/daemon.json`.

### Create Configuration File if Necessary:
If the file does not exist, create it using:

```bash
sudo touch /etc/docker/daemon.json
```

## 2. Edit Docker Configuration
Use a text editor to modify the configuration file:

```bash
sudo nano /etc/docker/daemon.json
```

Add or modify the following lines to set the desired memory limit:

```json
{
  "default-runtime": "runc",
  "runtimes": {
      "runc": {
          "path": "runc"
      }
  },
  "resources": {
    "memory": "4G"
  }
}
```

Replace `"4G"` with the amount of memory you want to allocate to Docker. For example, use `"8G"` for 8 gigabytes.

## 3. Restart Docker Service
After editing the configuration file, you need to restart the Docker service to apply the changes:

```bash
sudo systemctl restart docker
```

## 4. Verify Changes
To ensure your changes have taken effect, you can inspect the Docker daemon's current configuration:

```bash
docker info | grep -i memory
```

This command will show the memory limit currently set for Docker.

## Additional Notes
- **Permissions**: Ensure you have the necessary permissions to edit system files and restart Docker services.
- **Memory Limits**: The memory limit you set should not exceed your system's available memory.
- **Docker Version**: These instructions are generally applicable to recent Docker versions, but details might vary slightly depending on the exact version and system configuration.
