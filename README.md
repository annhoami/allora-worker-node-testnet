# allora-worker-node-testnet

## Start Akash

```bash
apt update && apt install tmux sudo wget curl -y && tmux
```

```bash
rm -rf allora.sh allora-chain/ basic-coin-prediction-node/
```

```bash
wget https://raw.githubusercontent.com/annhoami/allora-worker-node-testnet/main/allora.sh && chmod +x allora.sh && ./allora.sh
```

## Check running docker containers

```bash
# Ensure you are in the right directory
cd $HOME && cd basic-coin-prediction-node

# Check worker 1 logs
docker compose logs -f worker-1

# Check worker 2 logs
docker compose logs -f worker-2

docker compose logs -f worker-3

docker compose logs -f worker-4

docker compose logs -f worker-5

docker compose logs -f worker-6
```

## Check Topic 1

```bash
curl --location 'https://heads.testnet-1.testnet.allora.network/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "1",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "ETH"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```

## Check Topic 2

```bash
curl --location 'https://heads.testnet-1.testnet.allora.network/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "2",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "ETH"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```

## Check Topic 3

```bash
curl --location 'https://heads.testnet-1.testnet.allora.network/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "3",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "BTC"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```

## Check Topic 4

```bash
curl --location 'https://heads.testnet-1.testnet.allora.network/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "4",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "BTC"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```

## Check Topic 5

```bash
curl --location 'https://heads.testnet-1.testnet.allora.network/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "5",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "SOL"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```

## Check Topic 6

```bash
curl --location 'https://heads.testnet-1.testnet.allora.network/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "6",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "SOL"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```

## Error 408: when checking topic status

```bash
# Ensure you are in the right directory
cd $HOME && cd basic-coin-prediction-node

# Remove worker container
docker container stop $(docker ps -q)
docker container rm $(docker ps -aq)
```
```bash
docker compose up -d --build
```

## Reinstall docker containers

```bash
cd $HOME && cd basic-coin-prediction-node
rm -rf docker-compose.yml
rm allora-docker.sh
wget https://raw.githubusercontent.com/annhoami/allora-worker-node-testnet/main/allora-docker.sh && chmod +x allora-docker.sh && ./allora-docker.sh
```
