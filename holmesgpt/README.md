# HolmesGPT Docker Compose Setup

This directory contains a Docker Compose configuration to run HolmesGPT, an AI-powered Kubernetes troubleshooting tool.

## Prerequisites

Before running HolmesGPT, ensure you have:

1. **Docker and Docker Compose** installed on your system
2. **Kubernetes cluster access** with a valid `~/.kube/config` file
3. **Cloud credentials** (if applicable):
   - AWS: `~/.aws/` directory with credentials
   - Google Cloud: `~/.config/gcloud/` directory with credentials
   - Azure: `~/.azure/` directory with credentials

## Quick Start

1. **Start HolmesGPT**:
   ```bash
   docker-compose up -d
   ```

2. **Check if the service is running**:
   ```bash
   docker-compose ps
   ```

3. **Access the web interface**:
   Open your browser and go to: `http://localhost:8080`

4. **View logs**:
   ```bash
   # View CLI service logs
   docker-compose logs -f holmesgpt-cli
   
   # View API service logs
   docker-compose logs -f holmesgpt-api
   
   # View frontend service logs
   docker-compose logs -f holmesgpt-frontend
   
   # View all services logs
   docker-compose logs -f
   ```

## Using HolmesGPT

Once the container is running, you can interact with HolmesGPT using the following commands:

### Basic Commands

```bash
# Ask HolmesGPT about unhealthy pods
docker exec -it holmesgpt-cli python holmes_cli.py ask "what pods are unhealthy and why?"

# Get help about available commands
docker exec -it holmesgpt-cli python holmes_cli.py --help

# Check cluster status
docker exec -it holmesgpt-cli python holmes_cli.py ask "what is the overall health of my cluster?"

# Investigate specific issues
docker exec -it holmesgpt-cli python holmes_cli.py ask "why is my deployment failing?"

# Check available toolsets
docker exec -it holmesgpt-cli python holmes_cli.py toolset list
```

### Interactive Mode

You can also run HolmesGPT in interactive mode:

```bash
docker exec -it holmesgpt-cli python holmes_cli.py
```

This will start an interactive session where you can ask questions directly.

## Web Interface

HolmesGPT provides a modern web interface that you can access at `http://localhost:8080`. The web UI offers:

- **Interactive Chat**: Chat with HolmesGPT through a clean, modern interface
- **Quick Actions**: Pre-built queries for common troubleshooting tasks
- **Real-time Status**: Live connection status and API information
- **Responsive Design**: Works on desktop, tablet, and mobile devices

## Web API Access

HolmesGPT also provides a REST API that you can access at `http://localhost:3000`. The API includes the following endpoints:

### Available API Endpoints

- **GET `/api/model`** - Get current AI model information
- **POST `/api/chat`** - General chat with HolmesGPT
- **POST `/api/investigate`** - Investigate specific issues
- **POST `/api/workload_health_check`** - Check workload health
- **POST `/api/issue_chat`** - Chat about specific issues

### API Usage Examples

```bash
# Check the current model
curl http://localhost:3000/api/model

# Chat with HolmesGPT via API
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"ask": "What pods are unhealthy in my cluster?"}'

# Investigate an issue
curl -X POST http://localhost:3000/api/investigate \
  -H "Content-Type: application/json" \
  -d '{"issue": "High CPU usage on node worker-1"}'
```

### Building a Web UI

The API server provides the backend for building custom web interfaces. You can create your own frontend that communicates with these API endpoints to provide a web-based HolmesGPT experience.

## AI Model Configuration

HolmesGPT requires an AI model API key to provide intelligent responses. You can use any of the following providers:

### Option 1: Environment Variables
Create a `.env` file from the provided template:

```bash
# Copy the template
cp env.template .env

# Edit the .env file and uncomment the API key you want to use
nano .env
```

Example `.env` file content:
```bash
# Uncomment and set your API key
OPENAI_API_KEY=your_openai_api_key_here
# OR
# ANTHROPIC_API_KEY=your_anthropic_api_key_here
# OR
# AZURE_OPENAI_API_KEY=your_azure_openai_key_here
# AZURE_OPENAI_ENDPOINT=your_azure_endpoint_here
```

Then restart the services:
```bash
docker-compose down && docker-compose up -d
```

### Option 2: Direct Environment Variables
Export the API key in your shell before running docker-compose:

```bash
export OPENAI_API_KEY="your_api_key_here"
docker-compose up -d
```

### Supported AI Models
- **OpenAI**: GPT-4, GPT-3.5-turbo (requires `OPENAI_API_KEY`)
- **Anthropic**: Claude models (requires `ANTHROPIC_API_KEY`)
- **Azure OpenAI**: Azure-hosted models (requires `AZURE_OPENAI_API_KEY` and `AZURE_OPENAI_ENDPOINT`)
- **Google**: Gemini models (requires `GOOGLE_API_KEY`)

## Configuration

### Volume Mounts

The docker-compose.yml file mounts the following directories:

- `~/.holmes` - HolmesGPT configuration directory
- `~/.kube/config` - Kubernetes configuration (read-only)
- `~/.aws` - AWS credentials (read-only, if applicable)
- `~/.config/gcloud` - Google Cloud credentials (read-only, if applicable)
- `~/.azure` - Azure credentials (read-only, if applicable)

### Network Mode

The service uses `host` network mode for easy access to your Kubernetes cluster. If you prefer bridge networking, uncomment the ports section and networks configuration in the docker-compose.yml file.

## Troubleshooting

### Common Issues

1. **Permission Issues**: Ensure your credential files have proper permissions:
   ```bash
   chmod 600 ~/.kube/config
   chmod -R 600 ~/.aws/
   ```

2. **Kubernetes Connection Issues**: Verify your kubectl works:
   ```bash
   kubectl get pods
   ```

3. **Container Won't Start**: Check the logs:
   ```bash
   # Check CLI service logs
   docker-compose logs holmesgpt-cli
   
   # Check API service logs
   docker-compose logs holmesgpt-api
   ```

### Stopping the Service

```bash
# Stop the service
docker-compose down

# Stop and remove volumes (if needed)
docker-compose down -v
```

## Advanced Configuration

You can customize the configuration by:

1. Modifying environment variables in the docker-compose.yml
2. Creating a `.env` file for environment-specific settings
3. Adjusting volume mounts based on your setup

For more advanced configurations and detailed documentation, visit the [HolmesGPT Documentation](https://holmesgpt.dev/).
