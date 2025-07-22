#!/bin/bash

# Dotfiles Test Runner
# This script runs the dotfiles tests in a Docker container

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    error "Docker is not running. Please start Docker and try again."
fi

# Parse command line arguments
case "${1:-test}" in
    "test")
        info "Running dotfiles tests in Docker container..."
        docker compose -f docker-compose.test.yml build dotfiles-test
        docker compose -f docker-compose.test.yml run --rm dotfiles-test
        ;;
    "interactive")
        info "Starting interactive test environment..."
        docker compose -f docker-compose.test.yml build dotfiles-interactive
        docker compose -f docker-compose.test.yml run --rm dotfiles-interactive
        ;;
    "clean")
        info "Cleaning up test containers and images..."
        docker compose -f docker-compose.test.yml down --rmi all -v || true
        docker system prune -f
        success "Cleanup completed"
        ;;
    "help"|"-h"|"--help")
        echo "Dotfiles Test Runner"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  test         Run automated tests (default)"
        echo "  interactive  Start interactive test environment"
        echo "  clean        Clean up Docker containers and images"
        echo "  help         Show this help message"
        ;;
    *)
        error "Unknown command: $1. Use '$0 help' for available commands."
        ;;
esac