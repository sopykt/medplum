#!/usr/bin/env bash

# Fail on error
set -e

# Change directory to project root if script is run from elsewhere
cd "$(dirname "$0")/.."

echo "🚀 Starting Medplum local development stack setup..."

# 1. Install dependencies
echo "📦 Installing npm dependencies..."
npm ci --strict-peer-deps

# 2. Build the project
echo "🛠️  Building the project (fast build)..."
npm run build:fast

# 3. Start PostgreSQL and Redis Docker containers
echo "🐳 Starting Postgres and Redis Docker services..."
docker compose -f docker-compose.full-stack.yml up -d postgres redis

echo "✅ Medplum local setup is ready!"
echo ""
echo "To run the API Server:"
echo "  1. Navigate to: cd packages/server"
echo "  2. Run dev server: npm run dev"
echo ""
echo "To run the Web App:"
echo "  1. Navigate to: cd packages/app"
echo "  2. Run dev server: npm run dev"
echo ""
echo "Once both are running:"
echo "  - Access Web App at http://localhost:3000"
echo "  - Login Email: admin@example.com"
echo "  - Login Password: medplum_admin"
