#!/bin/bash

# HolmesGPT Native Linux Installation Script
# This script installs HolmesGPT directly on Linux without Docker

set -e

echo "🔍 HolmesGPT Native Linux Installation"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Python 3 is installed
print_header "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
print_status "Found Python $PYTHON_VERSION"

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    print_error "pip3 is not installed. Please install pip3."
    exit 1
fi

# Check if Docker is installed and accessible
print_header "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    print_warning "Docker is not installed. Docker toolset will not be available."
    print_status "To install Docker, run: curl -fsSL https://get.docker.com | sh"
else
    print_status "Docker is installed"
    
    # Check if user can run docker commands
    if ! docker ps &> /dev/null; then
        print_warning "Cannot run Docker commands. You may need to:"
        print_warning "1. Add your user to the docker group: sudo usermod -aG docker \$USER"
        print_warning "2. Log out and log back in"
        print_warning "3. Or run: newgrp docker"
    else
        print_status "Docker is accessible"
    fi
fi

# Install HolmesGPT
print_header "Installing HolmesGPT..."
pip3 install --user holmesgpt

# Create HolmesGPT configuration directory
print_header "Setting up configuration..."
HOLMES_CONFIG_DIR="$HOME/.holmes"
mkdir -p "$HOLMES_CONFIG_DIR"

# Create configuration file with Docker toolset enabled
cat > "$HOLMES_CONFIG_DIR/config.yaml" << 'EOF'
# HolmesGPT Configuration
# This file configures the available toolsets for HolmesGPT

toolsets:
  # Docker toolset for container management and monitoring
  docker/core:
    enabled: true
  
  # Kubernetes toolset (default)
  kubernetes/core:
    enabled: true
  
  # Additional useful toolsets
  datetime/core:
    enabled: true
  
  # Uncomment these if you have the services configured:
  # prometheus/core:
  #   enabled: true
  # loki/core:
  #   enabled: true
  # github/core:
  #   enabled: true
EOF

print_status "Created configuration file at $HOLMES_CONFIG_DIR/config.yaml"

# Check if kubectl is available
print_header "Checking Kubernetes configuration..."
if command -v kubectl &> /dev/null; then
    if kubectl cluster-info &> /dev/null; then
        print_status "Kubernetes cluster is accessible"
    else
        print_warning "kubectl is installed but cluster is not accessible"
        print_warning "Make sure your ~/.kube/config is properly configured"
    fi
else
    print_warning "kubectl is not installed. Kubernetes toolset will have limited functionality."
fi

# Create environment setup script
print_header "Creating environment setup script..."
cat > "$HOME/setup-holmesgpt-env.sh" << 'EOF'
#!/bin/bash

# HolmesGPT Environment Setup
# Source this file to set up your environment for HolmesGPT

# Add user pip bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# AI Provider API Keys (uncomment and set as needed)
# export OPENAI_API_KEY="your_openai_api_key_here"
# export ANTHROPIC_API_KEY="your_anthropic_api_key_here"
# export AZURE_OPENAI_API_KEY="your_azure_openai_key_here"
# export AZURE_OPENAI_ENDPOINT="your_azure_endpoint_here"
# export GOOGLE_API_KEY="your_google_api_key_here"

# Optional: Set timezone
export TZ="UTC"

# Optional: Custom cluster name
export CLUSTER_NAME="local-cluster"

echo "HolmesGPT environment configured!"
echo "Available commands:"
echo "  holmes ask 'your question here'"
echo "  holmes toolset list"
echo "  holmes toolset refresh"
EOF

chmod +x "$HOME/setup-holmesgpt-env.sh"
print_status "Created environment setup script at $HOME/setup-holmesgpt-env.sh"

# Add to PATH if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    print_status "Added $HOME/.local/bin to PATH for this session"
    print_warning "To make PATH change permanent, add this line to your ~/.bashrc or ~/.zshrc:"
    print_warning "export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Refresh toolsets
print_header "Refreshing toolsets..."
if command -v holmes &> /dev/null; then
    holmes toolset refresh
    print_status "Toolsets refreshed successfully"
else
    print_warning "Holmes command not found in PATH. You may need to restart your shell or run:"
    print_warning "source $HOME/setup-holmesgpt-env.sh"
fi

print_header "Installation Complete!"
echo ""
print_status "HolmesGPT has been installed successfully!"
echo ""
echo "Next steps:"
echo "1. Set up your AI provider API key:"
echo "   - Edit $HOME/setup-holmesgpt-env.sh"
echo "   - Uncomment and set your API key (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.)"
echo ""
echo "2. Load the environment:"
echo "   source $HOME/setup-holmesgpt-env.sh"
echo ""
echo "3. Test the installation:"
echo "   holmes ask --help"
echo "   holmes toolset list"
echo ""
echo "4. Start using HolmesGPT:"
echo "   holmes ask 'what pods are unhealthy and why?'"
echo "   holmes ask 'show me all docker containers'"
echo ""
echo "For more information, visit: https://holmesgpt.dev/"
