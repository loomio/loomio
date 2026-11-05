# Push relay deployment

This stack adds an isolated PostgreSQL database, the relay, and an Nginx ingress to the existing `kamal` Docker network on photosarecool.com. It publishes no host ports. Kamal Proxy supplies HTTPS; Nginx limits registration to 30 requests per minute per client IP and signed routes to 300 requests per minute per client IP. The relay and database are reachable only on the stack's backend network. The relay signs APNs requests with environment-specific keys and sends only generic notification payloads.

## Prepare

Copy the push-relay directory to the deploy host. Create `deploy/.env` from `.env.example`, replacing both placeholders for random secrets and the two Apple Key IDs. Generate a database password with `openssl rand -hex 32` and the encryption key with `openssl rand -base64 32`. Keep the encryption key stable across deployments: existing token and delivery-key ciphertext depends on it.

Store the production key in `deploy/secrets/apns-production.p8` and the separate sandbox key in `deploy/secrets/apns-sandbox.p8`. Protect `.env` with mode `0600`. The secrets directory and its files must be readable by UID 1000 (the relay's unprivileged container user); use directory mode `0700` and file mode `0600` owned by that UID. The keys are mounted read-only and excluded from the image build context and Git.

Confirm the proxy network subnet with `docker network inspect kamal` and set `PROXY_TRUSTED_CIDR` accordingly. Only that network may supply forwarded client addresses. Ensure DNS for the chosen relay hostname points to photosarecool.com and permits Let's Encrypt validation.

## Start

Run from this directory:

```sh
docker compose build relay
docker compose up -d database
docker compose run --rm relay npm run migrate
docker compose up -d relay ingress
docker compose ps
docker exec kamal-proxy kamal-proxy deploy loomio-push-relay --host=push.loomio.com --target=loomio-push-relay-ingress:80 --tls --forward-headers --health-check-path=/health
curl --fail https://push.loomio.com/health
```

The ingress port is accessible only inside Docker. Nginx evaluates the last untrusted address in the forwarded chain, then overwrites the header before passing it to the relay. Do not publish the relay port or broaden the trusted network to public clients.

Configure `PUSH_RELAY_URL=https://push.loomio.com` on each participating Loomio host and restart its app and notification workers using that host's normal deployment process. The URL is public configuration; APNs signing keys stay on this relay and are never copied to the Loomio hosts. Leave `ALLOW_PRIVATE_HOSTS` unset.

## Verify

1. Connect the iOS app to the selected Loomio host and grant notification permission.
2. Confirm the app registers with the relay and can send its native test notification. Xcode Debug installations use Sandbox; TestFlight uses Production.
3. Put the app in the background and trigger a real notification for the connected account. Confirm the generic notification arrives and tapping it opens the host's notification page.
4. Repeat for each supported host. A host without relay configuration must not report push as registered.
5. Verify revoking or disconnecting the device stops delivery and removes the relay registration. Confirm APNs invalid-token responses also remove the registration.

## Operations

Back up the PostgreSQL volume together with the encryption key and APNs signing keys through the private backup system. Losing the encryption key requires all devices to register again. Do not enable the host configuration until the relay, HTTPS, and a restore procedure have been verified.

Deploy updates by rebuilding, running migrations, and recreating relay/ingress. For rollback, restore the previous relay image and compatible schema; do not delete the database volume. To stop new mobile deliveries without changing other notification channels, unset `PUSH_RELAY_URL` on the Loomio hosts and restart their app and notification workers.
