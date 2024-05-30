## Hardware Requirements

- All in one:
  - 1TB+ SSD, 16+ CPU cores, 128GB RAM
- Separate:
  - Validator: 8GB RAM, 4+ CPU cores, ~80GB+ SSD/nvme storage
  - Bitcoin full node: 1TB+ SSD/nvme storage, 8+ CPU cores, 96GB+ RAM


## System Configuration

### Setup
- Clone the Repository
  ```bash
  git clone https://github.com/blockchain-insights/blockchain-data-subnet-ops
  ```
- Navigate to ```blockchain-data-subnet-ops/validator``` and copy the example ```.env``` file:
  ```bash
  cp .env.example .env
  ```

### Monitoring by Subnet 15 team

To improve the subnet you can send telemery and logs accessible only to the subnet 15 team by installing the Docker Loki Pluging. By monitoring the subnet efficiency and errors we can be pro-active by detecting issues promptly.

> [!NOTE] We don't collect sensible information like usersname or passwords.

> Documentation Reference: [Grafana Loki Plugin Documentation](https://grafana.com/docs/loki/latest/send-data/docker-driver/)

1. Docker command to install Plugin

```bash
docker plugin install grafana/loki-docker-driver:2.9.8 --alias loki --grant-all-permissions
```

2. Verify that the Docker Plugin is installed

```bash
docker plugin ls
```

Expected output:
```
ID                  NAME         DESCRIPTION           ENABLED
ac720b8fcfdb        loki         Loki Logging Driver   true
```

>[!WARNING] To take effect you need to restart the Docker daemon, this will shutdown all docker copose services and restart them.

```bash
sudo systemctl restart docker
```

###### please reach subnet 15 team to whitelist your validator ip address

### Subtensor, Bitcoin Node, PGSql,Validator
**Running Local Subtensor (optional but recommended)**

- Start the subtensor:
  ```bash
  docker compose up -d node-subtensor
  ```

**Running Bitcoin node**

- Open the ```.env``` file:
  ```bash
  nano .env
  ```
- Set the required variables in the ```.env``` file and save it:
  ```ini
  RPC_USER=your_secret_user_name
  RPC_PASSWORD=your_secret_password
  ```

  **Optional ```.env``` variables with their defaults. Add them to your ```.env``` file ONLY if you are not satisfied with the defaults:**
  ```ini
  RPC_ALLOW_IP=172.16.0.0/12
  RPC_BIND=0.0.0.0
  MAX_CONNECTIONS=512
  ```

- Start the Bitcoin node:
  ```bash
  docker compose up -d bitcoin-core
  ```

**Running postgresql**
- Open the ```.env``` file:
  ```
  nano .env
  ```

- Set the required variables in the ```.env``` file and save it:
  ```ini
  POSTGRES_DB=validator
  POSTGRES_USER=postgres
  POSTGRES_PASSWORD=changeit456$
  ```

  - Start postgres
  ```
  docker compose up -d postgres
  ```
  
**Running Validator**

- Open the ```.env``` file:
  ```
  nano .env
  ```

- Set the required variables in the ```.env``` file and save it:
  ```ini
  WALLET_NAME=default
  WALLET_HOTKEY=default
  ```

  **Optional ```.env``` variables with their defaults. Add them to your ```.env``` file ONLY if you are not satisfied with the defaults:**
  ```ini
  # If you want to use enternal Bitcoin node RPC.
  BITCOIN_NODE_RPC_URL=http://${RPC_USER}:${RPC_PASSWORD}@bitcoin-core:8332
  # If you have custom bittensor path
  BITTENSOR_VOLUME_PATH=~/.bittensor
  # By default validators use local subtensor node, but you can specify a different one
  SUBTENSOR_NETWORK=local
  SUBTENSOR_URL=ws://IP:PORT
  ```
- Start Validator
  ```bash
  docker compose up -d validator
  ```

- [OPTIONAL] Start Validator without loki logging
  ```bash
  docker compose up -d validator-no-logger
  ```

- [OPTIONAL] Start Validator with automatic updates
  ```bash
  nohup ./run.sh 2>&1 &
  ```

**Whitelist Validator Hotkey**
  
You should whitelist your validator hotkey by reaching aphex5 on Discord.
Currently whitelisted and blacklisted hotkeys can be found [here](https://subnet-15-cfg.s3.fr-par.scw.cloud/miner.json).
  
### Monitoring with Dozzle (only for you)

To easily monitor your containers, you can start Dozzle:
```bash
docker run -d --name dozzle --restart unless-stopped --volume=/var/run/docker.sock:/var/run/docker.sock --volume /root/dozzle:/data -p 9999:8080 amir20/dozzle:latest --auth-provider simple
```

Then navigate to `/dozzle` directory and generate your password sha256 `echo -n 'secret-password' | sha256sum`
In next step execute `nano users.yml` and paste following content:

```
users:
  # "admin" here is username
  admin:
    name: "admin"
    # Just sha-256 which can be computed with "echo -n password | shasum -a 256"
    password: "YOUR_HASH_GOES_HERE"
    email: some@email.net
```

At the end, restart the container by executing `docker container restart dozzle`

Then navigate to ```http://your_server_ip:9999```

### Updating
If the validator is started by nohup, it will update automatically once the new Docker image is published.

### Manual Upgrading

- check the latest base package version [here](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base)
- update the repository
    ```bash 
    git pull
    ```
- check the ```VERSION``` variable in your ```.env``` file and update it to match the new version if needed or `latest` will always pull the current version
    ```bash
    cat .env
    ```
- update the images
    ```bash
    docker compose pull
    ```
- restart containers
    ```bash
    docker compose up -d validator
    ```
- if needed restart other containers too
- when additional changes are needed, they will be announced on Discord
