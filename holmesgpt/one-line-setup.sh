#!/bin/bash

# One-Line HolmesGPT Setup
# This creates a simple command to set up your API key instantly

echo "Creating one-line setup commands..."

# Create individual setup functions
cat > ~/.holmes-setup-functions.sh << 'EOF'
# HolmesGPT One-Line Setup Functions

setup-holmes-openai() {
    if [ -z "$1" ]; then
        echo "Usage: setup-holmes-openai YOUR_API_KEY"
        return 1
    fi
    echo "export OPENAI_API_KEY=\"$1\"" >> ~/.zshrc
    export OPENAI_API_KEY="$1"
    echo "✅ OpenAI API key configured! Restart terminal or run: source ~/.zshrc"
}

setup-holmes-anthropic() {
    if [ -z "$1" ]; then
        echo "Usage: setup-holmes-anthropic YOUR_API_KEY"
        return 1
    fi
    echo "export ANTHROPIC_API_KEY=\"$1\"" >> ~/.zshrc
    export ANTHROPIC_API_KEY="$1"
    echo "✅ Anthropic API key configured! Restart terminal or run: source ~/.zshrc"
}

setup-holmes-azure() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: setup-holmes-azure YOUR_API_KEY YOUR_ENDPOINT"
        return 1
    fi
    echo "export AZURE_OPENAI_API_KEY=\"$1\"" >> ~/.zshrc
    echo "export AZURE_OPENAI_ENDPOINT=\"$2\"" >> ~/.zshrc
    export AZURE_OPENAI_API_KEY="$1"
    export AZURE_OPENAI_ENDPOINT="$2"
    echo "✅ Azure OpenAI configured! Restart terminal or run: source ~/.zshrc"
}

setup-holmes-google() {
    if [ -z "$1" ]; then
        echo "Usage: setup-holmes-google YOUR_API_KEY"
        return 1
    fi
    echo "export GOOGLE_API_KEY=\"$1\"" >> ~/.zshrc
    export GOOGLE_API_KEY="$1"
    echo "✅ Google API key configured! Restart terminal or run: source ~/.zshrc"
}

# Quick test function
test-holmes() {
    echo "🧪 Testing HolmesGPT..."
    if holmes ask "hello" > /dev/null 2>&1; then
        echo "✅ HolmesGPT is working!"
        echo "🐳 Try: holmes ask 'what docker containers are running?'"
    else
        echo "❌ Test failed. Check your API key setup."
    fi
}
EOF

# Add to .zshrc if not already there
if ! grep -q ".holmes-setup-functions.sh" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# HolmesGPT Setup Functions" >> ~/.zshrc
    echo "[ -f ~/.holmes-setup-functions.sh ] && source ~/.holmes-setup-functions.sh" >> ~/.zshrc
fi

echo "✅ One-line setup functions created!"
echo ""
echo "🚀 Usage (restart terminal or run: source ~/.zshrc):"
echo ""
echo "For OpenAI:"
echo "  setup-holmes-openai sk-your-api-key-here"
echo ""
echo "For Anthropic:"
echo "  setup-holmes-anthropic your-anthropic-key"
echo ""
echo "For Azure OpenAI:"
echo "  setup-holmes-azure your-key https://your-endpoint.openai.azure.com/"
echo ""
echo "For Google:"
echo "  setup-holmes-google your-google-key"
echo ""
echo "Test setup:"
echo "  test-holmes"
