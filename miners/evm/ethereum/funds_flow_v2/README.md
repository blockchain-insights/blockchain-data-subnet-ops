
# How to setup ethereum archive node

1. Install Docker
2. Modify `.env` files if necessary (updates announced on Discord).
3. Create `jwt.hex` file
- Install `prysm`
``````
curl https://raw.githubusercontent.com/prysmaticlabs/prysm/master/prysm.sh --output prysm.sh && chmod +x prysm.sh
``````
- Generate JWT Secret
``````
./prysm.sh beacon-chain generate-auth-secret
``````
4. Restart containers with `docker-compose up -d`.
