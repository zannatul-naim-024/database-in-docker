#!/bin/bash

# HolmesGPT API Key Setup Script
# This script helps you set up your API key permanently

echo "🔑 HolmesGPT API Key Setup"
echo "=========================="

# Function to add API key to zsh profile
setup_zsh_profile() {
    local api_key="$1"
    local provider="$2"
    local env_var="$3"
    
    # Backup existing .zshrc
    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
        echo "✅ Backed up existing .zshrc"
    fi
    
    # Remove any existing HolmesGPT API key entries
    sed -i '/# HolmesGPT API Key/d' ~/.zshrc 2>/dev/null || true
    sed -i '/export.*API_KEY.*holmes/Id' ~/.zshrc 2>/dev/null || true
    
    # Add new API key
    echo "" >> ~/.zshrc
    echo "# HolmesGPT API Key - Added $(date)" >> ~/.zshrc
    echo "export $env_var=\"$api_key\"" >> ~/.zshrc
    
    echo "✅ Added $provider API key to ~/.zshrc"
    echo "✅ API key will be automatically loaded in new terminal sessions"
}

# Function to create .env file
create_env_file() {
    local api_key="$1"
    local provider="$2"
    local env_var="$3"
    
    cat > ~/.holmes/.env << EOF
# HolmesGPT Environment Configuration
# Created: $(date)

# $provider API Key
$env_var=$api_key

# Optional: Custom model settings
# HOLMES_MODEL=gpt-4o
# HOLMES_MAX_STEPS=10

# Optional: Timezone
TZ=UTC
EOF
    
    echo "✅ Created ~/.holmes/.env file"
}

# Function to create wrapper script
create_wrapper_script() {
    local env_var="$3"
    
    cat > ~/holmes-with-key << 'EOF'
#!/bin/bash

# HolmesGPT Wrapper Script with Auto API Key Loading
# This script automatically loads your API key and runs holmes

# Load API key from .env file if it exists
if [ -f ~/.holmes/.env ]; then
    source ~/.holmes/.env
fi

# Load API key from shell profile
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
fi

# Check if API key is set
if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ] && [ -z "$AZURE_OPENAI_API_KEY" ] && [ -z "$GOOGLE_API_KEY" ]; then
    echo "❌ No API key found. Please run the setup script first."
    exit 1
fi

# Run holmes with all arguments
holmes "$@"
EOF
    
    chmod +x ~/holmes-with-key
    echo "✅ Created wrapper script at ~/holmes-with-key"
}

# Interactive setup
echo "Choose your AI provider:"
echo "1) OpenAI (GPT-4, GPT-3.5)"
echo "2) Anthropic (Claude)"
echo "3) Azure OpenAI"
echo "4) Google (Gemini)"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        provider="OpenAI"
        env_var="OPENAI_API_KEY"
        read -s -p "Enter your OpenAI API key: " api_key
        echo
        ;;
    2)
        provider="Anthropic"
        env_var="ANTHROPIC_API_KEY"
        read -s -p "Enter your Anthropic API key: " api_key
        echo
        ;;
    3)
        provider="Azure OpenAI"
        env_var="AZURE_OPENAI_API_KEY"
        read -s -p "Enter your Azure OpenAI API key: " api_key
        echo
        read -p "Enter your Azure OpenAI endpoint: " azure_endpoint
        ;;
    4)
        provider="Google"
        env_var="GOOGLE_API_KEY"
        read -s -p "Enter your Google API key: " api_key
        echo
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

if [ -z "$api_key" ]; then
    echo "❌ No API key provided"
    exit 1
fi

echo ""
echo "Setting up $provider API key..."

# Setup methods
echo ""
echo "Choose setup method:"
echo "1) Add to Zsh profile (recommended - automatic in all sessions)"
echo "2) Create .env file only"
echo "3) Both methods + wrapper script"
echo ""
read -p "Enter your choice (1-3): " method_choice

case $method_choice in
    1)
        setup_zsh_profile "$api_key" "$provider" "$env_var"
        if [ "$provider" = "Azure OpenAI" ] && [ -n "$azure_endpoint" ]; then
            echo "export AZURE_OPENAI_ENDPOINT=\"$azure_endpoint\"" >> ~/.zshrc
        fi
        ;;
    2)
        mkdir -p ~/.holmes
        create_env_file "$api_key" "$provider" "$env_var"
        ;;
    3)
        setup_zsh_profile "$api_key" "$provider" "$env_var"
        mkdir -p ~/.holmes
        create_env_file "$api_key" "$provider" "$env_var"
        create_wrapper_script "$api_key" "$provider" "$env_var"
        if [ "$provider" = "Azure OpenAI" ] && [ -n "$azure_endpoint" ]; then
            echo "export AZURE_OPENAI_ENDPOINT=\"$azure_endpoint\"" >> ~/.zshrc
            echo "AZURE_OPENAI_ENDPOINT=$azure_endpoint" >> ~/.holmes/.env
        fi
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "To start using HolmesGPT:"

if [ "$method_choice" = "1" ] || [ "$method_choice" = "3" ]; then
    echo "1. Restart your terminal OR run: source ~/.zshrc"
    echo "2. Test: holmes ask 'hello'"
fi

if [ "$method_choice" = "2" ]; then
    echo "1. Load environment: source ~/.holmes/.env"
    echo "2. Test: holmes ask 'hello'"
fi

if [ "$method_choice" = "3" ]; then
    echo "3. Or use wrapper: ~/holmes-with-key ask 'hello'"
fi

echo ""
echo "Docker integration is ready! Try:"
echo "  holmes ask 'what docker containers are running?'"
echo "  holmes ask 'show me container logs with errors'"
