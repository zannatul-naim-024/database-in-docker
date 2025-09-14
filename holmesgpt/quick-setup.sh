#!/bin/bash

# Quick HolmesGPT API Key Setup
# Usage: ./quick-setup.sh PROVIDER API_KEY
# Example: ./quick-setup.sh openai sk-your-api-key-here

if [ $# -lt 2 ]; then
    echo "Usage: $0 PROVIDER API_KEY"
    echo ""
    echo "Providers:"
    echo "  openai      - OpenAI (GPT-4, GPT-3.5)"
    echo "  anthropic   - Anthropic (Claude)"
    echo "  azure       - Azure OpenAI (requires endpoint as 3rd arg)"
    echo "  google      - Google (Gemini)"
    echo ""
    echo "Examples:"
    echo "  $0 openai sk-your-api-key-here"
    echo "  $0 anthropic your-anthropic-key-here"
    echo "  $0 azure your-azure-key-here https://your-endpoint.openai.azure.com/"
    exit 1
fi

PROVIDER="$1"
API_KEY="$2"
AZURE_ENDPOINT="$3"

# Determine environment variable name
case $PROVIDER in
    openai)
        ENV_VAR="OPENAI_API_KEY"
        ;;
    anthropic)
        ENV_VAR="ANTHROPIC_API_KEY"
        ;;
    azure)
        ENV_VAR="AZURE_OPENAI_API_KEY"
        if [ -z "$AZURE_ENDPOINT" ]; then
            echo "❌ Azure OpenAI requires endpoint as 3rd argument"
            exit 1
        fi
        ;;
    google)
        ENV_VAR="GOOGLE_API_KEY"
        ;;
    *)
        echo "❌ Unknown provider: $PROVIDER"
        echo "Use: openai, anthropic, azure, or google"
        exit 1
        ;;
esac

echo "🔑 Setting up $PROVIDER API key..."

# Backup existing .zshrc
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi

# Remove existing HolmesGPT entries
sed -i '/# HolmesGPT API Key/d' ~/.zshrc 2>/dev/null || true
sed -i '/export.*API_KEY.*holmes/Id' ~/.zshrc 2>/dev/null || true

# Add new API key to .zshrc
echo "" >> ~/.zshrc
echo "# HolmesGPT API Key - $(date)" >> ~/.zshrc
echo "export $ENV_VAR=\"$API_KEY\"" >> ~/.zshrc

if [ "$PROVIDER" = "azure" ]; then
    echo "export AZURE_OPENAI_ENDPOINT=\"$AZURE_ENDPOINT\"" >> ~/.zshrc
fi

# Also create .env file for backup
mkdir -p ~/.holmes
cat > ~/.holmes/.env << EOF
# HolmesGPT Environment Configuration
# Created: $(date)
$ENV_VAR=$API_KEY
EOF

if [ "$PROVIDER" = "azure" ]; then
    echo "AZURE_OPENAI_ENDPOINT=$AZURE_ENDPOINT" >> ~/.holmes/.env
fi

# Apply to current session
export $ENV_VAR="$API_KEY"
if [ "$PROVIDER" = "azure" ]; then
    export AZURE_OPENAI_ENDPOINT="$AZURE_ENDPOINT"
fi

echo "✅ API key configured for $PROVIDER"
echo "✅ Added to ~/.zshrc for automatic loading"
echo "✅ Created ~/.holmes/.env as backup"
echo "✅ Applied to current session"
echo ""
echo "🧪 Testing HolmesGPT..."

# Test the setup
if holmes ask "hello" > /dev/null 2>&1; then
    echo "✅ HolmesGPT is working!"
    echo ""
    echo "🐳 Try Docker commands:"
    echo "  holmes ask 'what docker containers are running?'"
    echo "  holmes ask 'show me container resource usage'"
else
    echo "❌ Test failed. Check your API key."
fi
