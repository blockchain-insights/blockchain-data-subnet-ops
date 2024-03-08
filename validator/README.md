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

### Subtensor, Bitcoin Node, Validator
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
  ```
  docker-compose up -d validator
  ```

**Whitelist Validator Hotkey**
  
You should whitelist your validator hotkey by reaching aphex5 on Discord.
Currently whitelisted and blacklisted hotkeys can be found [here](https://subnet-15-cfg.s3.fr-par.scw.cloud/miner.json).
  
### Monitoring

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

### Upgrading

- check the latest base package version [here](https://github.com/blockchain-insights/blockchain-data-subnet/pkgs/container/blockchain_insights_base)
- update the repository
    ```bash 
    git pull
    ```
- update the images
    ```bash
    docker compose pull
    ```
- check the ```VERSION``` variable in your ```.env``` file and update it to match the new version if needed
- restart containers
    ```bash
    docker compose up -d validator
    ```
- if needed restart other containers too
- when additional changes are needed, they will be announced on Discord
