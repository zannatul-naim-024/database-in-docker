#!/bin/bash

# HolmesGPT Installation Test Script
# This script tests the HolmesGPT installation and Docker toolset functionality

set -e

echo "🧪 Testing HolmesGPT Installation"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_test "Testing: $test_name"
    
    if eval "$test_command" &> /dev/null; then
        print_success "$test_name"
        ((TESTS_PASSED++))
        return 0
    else
        print_fail "$test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: Check if holmes command exists
run_test "Holmes command availability" "command -v holmes"

# Test 2: Check if Python can import holmesgpt
run_test "HolmesGPT Python import" "python3 -c 'import holmesgpt'"

# Test 3: Check holmes help
run_test "Holmes help command" "holmes --help"

# Test 4: Check configuration file exists
run_test "Configuration file exists" "test -f ~/.holmes/config.yaml"

# Test 5: Check Docker availability
if command -v docker &> /dev/null; then
    run_test "Docker command availability" "docker --version"
    run_test "Docker service accessibility" "docker ps"
else
    print_warning "Docker not installed - Docker toolset will not be available"
fi

# Test 6: Check kubectl availability (optional)
if command -v kubectl &> /dev/null; then
    run_test "Kubectl command availability" "kubectl version --client"
    if kubectl cluster-info &> /dev/null; then
        print_success "Kubernetes cluster accessible"
        ((TESTS_PASSED++))
    else
        print_warning "Kubectl installed but no cluster accessible"
    fi
else
    print_warning "Kubectl not installed - Kubernetes toolset will have limited functionality"
fi

# Test 7: Check toolset listing
print_test "Testing toolset listing"
if holmes toolset list &> /dev/null; then
    print_success "Toolset listing works"
    ((TESTS_PASSED++))
    
    # Check if Docker toolset is available
    if holmes toolset list | grep -q "docker/core"; then
        print_success "Docker toolset is available"
        ((TESTS_PASSED++))
    else
        print_fail "Docker toolset not found in toolset list"
        ((TESTS_FAILED++))
    fi
else
    print_fail "Toolset listing failed"
    ((TESTS_FAILED++))
fi

# Test 8: Check API key configuration
print_test "Checking API key configuration"
if [[ -n "$OPENAI_API_KEY" ]] || [[ -n "$ANTHROPIC_API_KEY" ]] || [[ -n "$AZURE_OPENAI_API_KEY" ]] || [[ -n "$GOOGLE_API_KEY" ]]; then
    print_success "AI provider API key is configured"
    ((TESTS_PASSED++))
else
    print_warning "No AI provider API key found. Set OPENAI_API_KEY, ANTHROPIC_API_KEY, AZURE_OPENAI_API_KEY, or GOOGLE_API_KEY"
fi

# Test 9: Test basic ask command (if API key is available)
if [[ -n "$OPENAI_API_KEY" ]] || [[ -n "$ANTHROPIC_API_KEY" ]] || [[ -n "$AZURE_OPENAI_API_KEY" ]] || [[ -n "$GOOGLE_API_KEY" ]]; then
    print_test "Testing basic ask functionality"
    if timeout 30 holmes ask "hello" &> /dev/null; then
        print_success "Basic ask command works"
        ((TESTS_PASSED++))
    else
        print_warning "Basic ask command failed or timed out - check API key and network"
    fi
else
    print_warning "Skipping ask command test - no API key configured"
fi

# Summary
echo ""
echo "Test Summary:"
echo "============="
print_success "Tests passed: $TESTS_PASSED"
if [ $TESTS_FAILED -gt 0 ]; then
    print_fail "Tests failed: $TESTS_FAILED"
else
    print_success "Tests failed: $TESTS_FAILED"
fi

echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    print_success "🎉 All tests passed! HolmesGPT is ready to use."
    echo ""
    echo "Try these commands:"
    echo "  holmes ask 'what is the current time?'"
    echo "  holmes ask 'show me all docker containers'"
    echo "  holmes ask 'list all kubernetes pods'"
else
    print_warning "⚠️  Some tests failed. Check the output above for issues."
    echo ""
    echo "Common fixes:"
    echo "  - Set up API key: export OPENAI_API_KEY='your_key_here'"
    echo "  - Install Docker: curl -fsSL https://get.docker.com | sh"
    echo "  - Add user to docker group: sudo usermod -aG docker \$USER"
    echo "  - Refresh toolsets: holmes toolset refresh"
fi

exit $TESTS_FAILED
