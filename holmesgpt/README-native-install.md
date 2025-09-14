# HolmesGPT Native Linux Installation

This guide helps you install HolmesGPT directly on your Linux system without Docker, including the Docker toolset for container management and monitoring.

## Quick Installation

Run the installation script:

```bash
./install-holmesgpt-native.sh
```

This script will:
- Install HolmesGPT via pip
- Create the configuration directory (`~/.holmes`)
- Set up the Docker toolset configuration
- Create an environment setup script
- Check system prerequisites

## Manual Installation Steps

If you prefer to install manually:

### 1. Install HolmesGPT

```bash
pip3 install --user holmesgpt
```

### 2. Add to PATH

Add the user pip bin directory to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 3. Create Configuration

Create the HolmesGPT configuration directory and file:

```bash
mkdir -p ~/.holmes
```

Create `~/.holmes/config.yaml`:

```yaml
toolsets:
  docker/core:
    enabled: true
  kubernetes/core:
    enabled: true
  datetime/core:
    enabled: true
```

### 4. Set Up API Key

Set your AI provider API key. For OpenAI:

```bash
export OPENAI_API_KEY="your_api_key_here"
```

Or add it to your shell profile for persistence.

### 5. Refresh Toolsets

```bash
holmes toolset refresh
```

## Docker Toolset Capabilities

Once installed, HolmesGPT will have access to the following Docker capabilities:

| Tool Name | Description |
|-----------|-------------|
| `docker_images` | List all Docker images |
| `docker_ps` | List all running Docker containers |
| `docker_ps_all` | List all Docker containers, including stopped ones |
| `docker_inspect` | Inspect detailed information about a Docker container or image |
| `docker_logs` | Fetch the logs of a Docker container |
| `docker_top` | Display the running processes of a container |
| `docker_events` | Get real-time events from the Docker server |
| `docker_history` | Show the history of an image |
| `docker_diff` | Inspect changes to files or directories on a container's filesystem |

## Usage Examples

### Basic Commands

```bash
# Get help
holmes ask --help

# List available toolsets
holmes toolset list

# Ask about Docker containers
holmes ask "show me all running docker containers"

# Ask about Docker images
holmes ask "what docker images do I have?"

# Investigate container issues
holmes ask "why is my nginx container not responding?"

# Check container logs
holmes ask "show me the logs for container webapp"

# Ask about Kubernetes and Docker together
holmes ask "what pods are running and what docker images are they using?"
```

### Advanced Queries

```bash
# Investigate performance issues
holmes ask "which docker containers are using the most CPU and memory?"

# Check container health
holmes ask "are there any unhealthy docker containers?"

# Analyze container networks
holmes ask "show me the network configuration of my containers"

# Historical analysis
holmes ask "what containers have been restarted recently and why?"
```

## Prerequisites

### Required
- Python 3.8 or higher
- pip3
- Linux system

### Optional but Recommended
- Docker (for Docker toolset functionality)
- kubectl (for Kubernetes toolset functionality)
- Access to AI provider (OpenAI, Anthropic, Azure OpenAI, or Google)

## Docker Access

For the Docker toolset to work, ensure:

1. Docker is installed:
   ```bash
   curl -fsSL https://get.docker.com | sh
   ```

2. Your user has Docker permissions:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. Docker service is running:
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

## Environment Setup

The installation script creates `~/setup-holmesgpt-env.sh` for environment configuration. Source it in each session:

```bash
source ~/setup-holmesgpt-env.sh
```

Or add it to your shell profile:

```bash
echo 'source ~/setup-holmesgpt-env.sh' >> ~/.bashrc
```

## Troubleshooting

### Command Not Found

If `holmes` command is not found:

```bash
# Check if it's in the right location
ls ~/.local/bin/holmes

# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Or reinstall
pip3 install --user --force-reinstall holmesgpt
```

### Docker Permission Denied

If you get Docker permission errors:

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Test Docker access
docker ps
```

### API Key Issues

Make sure your API key is properly set:

```bash
# Check if set
echo $OPENAI_API_KEY

# Set for current session
export OPENAI_API_KEY="your_key_here"

# Set permanently
echo 'export OPENAI_API_KEY="your_key_here"' >> ~/.bashrc
```

### Toolset Issues

If toolsets aren't working:

```bash
# Refresh toolsets
holmes toolset refresh

# List available toolsets
holmes toolset list

# Check configuration
cat ~/.holmes/config.yaml
```

## Updating HolmesGPT

To update to the latest version:

```bash
pip3 install --user --upgrade holmesgpt
holmes toolset refresh
```

## Uninstalling

To remove HolmesGPT:

```bash
pip3 uninstall holmesgpt
rm -rf ~/.holmes
rm ~/setup-holmesgpt-env.sh
```

## Support

- Documentation: https://holmesgpt.dev/
- GitHub: https://github.com/robusta-dev/holmesgpt
- Community: Join the HolmesGPT community meetups
