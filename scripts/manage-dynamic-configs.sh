#!/bin/bash

DYNAMIC_DIR="traefik/dynamic"

show_help() {
    cat << EOF
Dynamic Configuration Management

Usage: $0 [command] [options]

Commands:
    list                    List all dynamic configurations
    validate [file]         Validate YAML syntax
    create [service]        Create new service template
    enable [service]        Enable service (remove .disabled)
    disable [service]       Disable service (add .disabled)
    reload                  Reload Traefik configuration
    backup                  Backup all configurations

Examples:
    $0 list
    $0 validate homeassistant.yml
    $0 create jellyfin
    $0 disable nextcloud
    $0 reload
EOF
}

list_configs() {
    echo "=== Dynamic Configurations ==="
    echo "📁 Location: $DYNAMIC_DIR"
    echo ""
    echo "🟢 Active configurations:"
    find "$DYNAMIC_DIR" -name "*.yml" -not -name "*.disabled" | sort
    echo ""
    echo "🔴 Disabled configurations:"
    find "$DYNAMIC_DIR" -name "*.disabled" | sort
    echo ""
}

validate_config() {
    local file="$1"
    if [ -z "$file" ]; then
        echo "Validating all configurations..."
        for f in "$DYNAMIC_DIR"/*.yml; do
            if [ -f "$f" ]; then
                echo -n "$(basename "$f"): "
                python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>/dev/null && echo "✅ Valid" || echo "❌ Invalid"
            fi
        done
    else
        echo "Validating $file..."
        python3 -c "import yaml; yaml.safe_load(open('$DYNAMIC_DIR/$file'))" 2>/dev/null && echo "✅ Valid YAML" || echo "❌ Invalid YAML"
    fi
}

create_template() {
    local service="$1"
    local file="$DYNAMIC_DIR/${service}.yml"
    
    if [ -f "$file" ]; then
        echo "❌ Configuration for $service already exists"
        return 1
    fi
    
    cat > "$file" << EOF
# $service External Service Configuration
# Date: $(date +%Y-%m-%d)
# Author: $(whoami)

http:
  routers:
    $service:
      rule: "Host(\`${service}.octopod.eu\`)"
      entryPoints:
        - websecure
      service: $service
      middlewares:
        - authelia@docker
      tls:
        certResolver: letsencrypt

  services:
    $service:
      loadBalancer:
        servers:
          - url: "http://REPLACE-WITH-IP:PORT"
        healthCheck:
          path: /
          interval: 30s
          timeout: 10s
EOF
    
    echo "✅ Created template for $service"
    echo "📝 Edit $file to configure your service"
}

case "$1" in
    list)
        list_configs
        ;;
    validate)
        validate_config "$2"
        ;;
    create)
        if [ -z "$2" ]; then
            echo "❌ Service name required"
            show_help
            exit 1
        fi
        create_template "$2"
        ;;
    enable)
        if [ -f "$DYNAMIC_DIR/$2.disabled" ]; then
            mv "$DYNAMIC_DIR/$2.disabled" "$DYNAMIC_DIR/$2.yml"
            echo "✅ Enabled $2"
        else
            echo "❌ $2.disabled not found"
        fi
        ;;
    disable)
        if [ -f "$DYNAMIC_DIR/$2.yml" ]; then
            mv "$DYNAMIC_DIR/$2.yml" "$DYNAMIC_DIR/$2.disabled"
            echo "🔴 Disabled $2"
        else
            echo "❌ $2.yml not found"
        fi
        ;;
    reload)
        echo "🔄 Reloading Traefik configuration..."
        docker-compose restart traefik
        ;;
    backup)
        backup_dir="backups/dynamic-$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        cp -r "$DYNAMIC_DIR"/* "$backup_dir"
        echo "✅ Backed up to $backup_dir"
        ;;
    *)
        show_help
        ;;
esac
