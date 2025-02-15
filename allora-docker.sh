#!/bin/bash

BOLD="\033[1m"
UNDERLINE="\033[4m"
DARK_YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RESET="\033[0;32m"

execute_with_prompt() {
    echo -e "${BOLD}Executing: $1${RESET}"
    if eval "$1"; then
        echo "Command executed successfully."
    else
        echo -e "${BOLD}${DARK_YELLOW}Error executing command: $1${RESET}"
        exit 1
    fi
}

echo -e "${BOLD}${DARK_YELLOW}This is your Head ID:${RESET}"
cat head-data/keys/identity
echo

if [ -f docker-compose.yml ]; then
    rm docker-compose.yml
    echo "Removed existing docker-compose.yml file."
    echo
fi

read -p "Enter HEAD_ID: " HEAD_ID
echo

read -p "Enter WALLET_SEED_PHRASE: " WALLET_SEED_PHRASE
echo

echo -e "${BOLD}${UNDERLINE}${DARK_YELLOW}Generating docker-compose.yml file...${RESET}"
cat <<EOF > docker-compose.yml
version: '3'

services:
  inference:
    container_name: inference
    build:
      context: .
    command: python -u /app/app.py
    ports:
      - "8000:8000"
    networks:
      eth-model-local:
        aliases:
          - inference
        ipv4_address: 172.22.0.4
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/inference/ETH"]
      interval: 30s
      timeout: 30s
      retries: 12
    volumes:
      - ./inference-data:/app/data
  
  updater:
    container_name: updater
    build: .
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
    command: >
      sh -c "
      while true; do
        python -u /app/update_app.py;
        sleep 24h;
      done
      "
    depends_on:
      inference:
        condition: service_healthy
    networks:
      eth-model-local:
        aliases:
          - updater
        ipv4_address: 172.22.0.5
  
  head:
    container_name: head
    image: alloranetwork/allora-inference-base-head:latest
    environment:
      - HOME=/data
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=head --peer-db=/data/peerdb --function-db=/data/function-db  \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9010 --rest-api=:6000 \
          --boot-nodes=/dns/head-0-testnet-1.allora.nodium.xyz/tcp/30123/p2p/12D3KooWFFUp12NVyUE8upbjtr6Kjt7XfYtaCnB3Sm3wqxnmaBZV,/dns/head-0-testnet-1.allora.nodium.xyz/tcp/30124/ws/p2p/12D3KooWFFUp12NVyUE8upbjtr6Kjt7XfYtaCnB3Sm3wqxnmaBZV
    ports:
      - "6000:6000"
    volumes:
      - ./head-data:/data
    working_dir: /data
    networks:
      eth-model-local:
        aliases:
          - head
        ipv4_address: 172.22.0.100

  worker-1:
    container_name: worker-1
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9011 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/$HEAD_ID \
          --topic=allora-topic-1-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='$WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=http://allora-testnet-1-rpc.testnet.nodium.xyz:26657 \
          --allora-chain-key-name=worker-1 \
          --allora-chain-topic-id=1
    volumes:
      - ./workers/worker-1:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker1
        ipv4_address: 172.22.0.12

  worker-2:
    container_name: worker-2
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9013 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/$HEAD_ID \
          --topic=allora-topic-2-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='$WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=http://allora-testnet-1-rpc.testnet.nodium.xyz:26657 \
          --allora-chain-key-name=worker-2 \
          --allora-chain-topic-id=2
    volumes:
      - ./workers/worker-2:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker1
        ipv4_address: 172.22.0.13

  worker-3:
    container_name: worker-3
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9015 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/$HEAD_ID \
          --topic=allora-topic-3-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='$WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=http://allora-testnet-1-rpc.testnet.nodium.xyz:26657 \
          --allora-chain-key-name=worker-3 \
          --allora-chain-topic-id=3
    volumes:
      - ./workers/worker-3:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker3
        ipv4_address: 172.22.0.14

  worker-4:
    container_name: worker-4
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9017 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/$HEAD_ID \
          --topic=allora-topic-4-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='$WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=http://allora-testnet-1-rpc.testnet.nodium.xyz:26657 \
          --allora-chain-key-name=worker-4 \
          --allora-chain-topic-id=4
    volumes:
      - ./workers/worker-4:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker4
        ipv4_address: 172.22.0.15

  worker-5:
    container_name: worker-5
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9019 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/$HEAD_ID \
          --topic=allora-topic-5-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='$WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=http://allora-testnet-1-rpc.testnet.nodium.xyz:26657 \
          --allora-chain-key-name=worker-5 \
          --allora-chain-topic-id=5
    volumes:
      - ./workers/worker-5:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker5
        ipv4_address: 172.22.0.16

  worker-6:
    container_name: worker-6
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9021 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/$HEAD_ID \
          --topic=allora-topic-6-worker --allora-chain-worker-mode=worker \
          --allora-chain-restore-mnemonic='$WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=http://allora-testnet-1-rpc.testnet.nodium.xyz:26657 \
          --allora-chain-key-name=worker-6 \
          --allora-chain-topic-id=6
    volumes:
      - ./workers/worker-6:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker6
        ipv4_address: 172.22.0.17

networks:
  eth-model-local:
    driver: bridge
    ipam:
      config:
        - subnet: 172.22.0.0/24

volumes:
  inference-data:
  workers:
  head-data:
EOF

echo -e "${BOLD}${DARK_YELLOW}docker-compose.yml file generated successfully!${RESET}"
echo

echo -e "${BOLD}${UNDERLINE}${DARK_YELLOW}Building and starting Docker containers...${RESET}"
docker-compose build
docker-compose up -d
echo

echo -e "${BOLD}${DARK_YELLOW}Checking running Docker containers...${RESET}"
docker ps
echo
