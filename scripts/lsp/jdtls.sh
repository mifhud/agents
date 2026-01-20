#!/usr/bin/env bash

# ============================================
# JDTLS Wrapper Script dengan Java 21
# ============================================

# Path ke Java 21 (SESUAIKAN DENGAN SISTEM ANDA)
export JAVA_21_HOME="/usr/lib/jvm/open-jdk21"  # Linux
# export JAVA_21_HOME="/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home"  # macOS
# export JAVA_21_HOME="/usr/lib/jvm/java-21-openjdk-amd64"  # Ubuntu/Debian

# Path ke instalasi jdtls
JDTLS_HOME="/usr/lib/jdtls"

# Set JAVA_HOME ke Java 21 untuk jdtls
export JAVA_HOME="$JAVA_21_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

# Deteksi OS untuk config yang tepat
case "$(uname -s)" in
    Linux*)     CONFIG_DIR="$JDTLS_HOME/config_linux";;
    Darwin*)    CONFIG_DIR="$JDTLS_HOME/config_mac";;
    *)          CONFIG_DIR="$JDTLS_HOME/config_linux";;
esac

# Temukan jar launcher (versi bisa berbeda)
LAUNCHER_JAR=$(find "$JDTLS_HOME/plugins" -name "org.eclipse.equinox.launcher_*.jar" | head -n 1)

if [ -z "$LAUNCHER_JAR" ]; then
    echo "Error: Launcher jar not found in $JDTLS_HOME/plugins"
    exit 1
fi

# Workspace directory (setiap project berbeda)
# OpenCode akan set ini via working directory
WORKSPACE="${1:-$PWD}"
WORKSPACE_DATA="$WORKSPACE/.jdtls-workspace"

# Memory settings
XMX=${XMX:-2G}

# Debug mode (uncomment untuk troubleshooting)
# DEBUG_FLAGS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044"

# Jalankan jdtls
exec "$JAVA_HOME/bin/java" \
    $DEBUG_FLAGS \
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \
    -Dosgi.bundles.defaultStartLevel=4 \
    -Declipse.product=org.eclipse.jdt.ls.core.product \
    -Dlog.protocol=true \
    -Dlog.level=ALL \
    -Xmx${XMX} \
    -Xms100m \
    -Xlog:disable \
    --add-modules=ALL-SYSTEM \
    --add-opens java.base/java.util=ALL-UNNAMED \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    -jar "$LAUNCHER_JAR" \
    -configuration "$CONFIG_DIR" \
    -data "$WORKSPACE_DATA" \
    "$@"
