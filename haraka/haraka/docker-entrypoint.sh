#!/bin/sh

# runCmd prints the given command and runs it.
runCmd() {
  (set -x; $@)
}

# Execution
set -e

# Install APK (Alpine Package Keeper) packages if required.
# if [ ! -z "$APK_INSTALL_PACKAGES" ]; then
#   packages="$(echo $APK_INSTALL_PACKAGES | sed 's/,/ /g')"
#   runCmd apk add --update $packages

#   rm -rf /var/cache/apk/*
# fi

# Specify actual hostname.
echo "$REPLY_HOSTNAME" > /haraka/config/me
echo "$REPLY_HOSTNAME" > /haraka/config/host_list

# Configure STARTTLS after ACME has made both files readable. Deployments keep
# accepting mail while a certificate is initially being provisioned.
configure_tls() {
  [ -r "$HARAKA_TLS_KEY_PATH" ] && [ -r "$HARAKA_TLS_CERT_PATH" ] || return 1

  if ! grep -q '^tls$' /haraka/config/plugins; then
    sed -i 's/^# tls$/tls/' /haraka/config/plugins
  fi

  if [ ! -f /haraka/config/tls.ini ]; then
    cat > /haraka/config/tls.ini <<EOF
[main]
key=$HARAKA_TLS_KEY_PATH
cert=$HARAKA_TLS_CERT_PATH
minVersion=TLSv1.2
EOF
  fi
}

# ACME renewals replace the certificate files without restarting Haraka.
# Watch their contents and gracefully replace Haraka's worker after a change,
# so new SMTP connections use the renewed certificate without dropping mail.
watch_tls() {
  tls_fingerprint="$1"

  while true; do
    if configure_tls; then
      tls_fingerprint_next="$(cksum "$HARAKA_TLS_KEY_PATH" "$HARAKA_TLS_CERT_PATH")"
      if [ "$tls_fingerprint_next" != "$tls_fingerprint" ]; then
        echo "TLS certificate appeared or changed; gracefully reloading Haraka"
        /opt/haraka/node_modules/.bin/haraka -c /haraka --graceful
      fi
      tls_fingerprint="$tls_fingerprint_next"
    fi

    sleep "${HARAKA_TLS_RELOAD_INTERVAL_SECONDS:-60}"
  done
}

if [ -n "$HARAKA_TLS_KEY_PATH" ] && [ -n "$HARAKA_TLS_CERT_PATH" ]; then
  if configure_tls; then
    echo "STARTTLS enabled"
    tls_fingerprint="$(cksum "$HARAKA_TLS_KEY_PATH" "$HARAKA_TLS_CERT_PATH")"
  else
    echo "TLS certificate files are not readable yet; starting without STARTTLS"
    tls_fingerprint=""
  fi

  watch_tls "$tls_fingerprint" &
fi

# currDir="$(pwd)"
# cd "$HARAKA_HOME"
# runCmd npm install
# runCmd npm install axios@0.27.2
# cd "$currDir"

# might remove this
# Install plugins from NPM if required.
# if [ ! -z "$HARAKA_INSTALL_PLUGINS" ]; then
#   currDir="$(pwd)"
#   cd "$HARAKA_HOME"

#   plugins="$(echo $HARAKA_INSTALL_PLUGINS | sed 's/,/ /g')"
#   runCmd npm install $plugins

#   cd "$currDir"
# fi

case "$1" in
  -*) exec /opt/haraka/node_modules/.bin/haraka "$@" ;;
  *) exec "$@" ;;
esac
