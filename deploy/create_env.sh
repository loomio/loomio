#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 hostname email@address.com" >&2
  exit 1
fi

hostname="$1"
support_email="$2"
script_dir=$(cd "$(dirname "$0")" && pwd)
template_file="$script_dir/env_template"
generator_image="${VAPID_GENERATOR_IMAGE:-loomio/loomio:3.5}"
env_file="$PWD/.env"

if [ -e "$env_file" ]; then
  echo "$env_file already exists; no changes were made" >&2
  exit 1
fi
if [ ! -f "$template_file" ]; then
  echo "Cannot find $template_file" >&2
  exit 1
fi
umask 077
generated_file=$(mktemp "$PWD/.env.tmp.XXXXXX")
created=false
trap 'if [ "$created" != true ]; then rm -f "$generated_file"; fi' EXIT

docker run --rm \
  --volume "$template_file:/opt/loomio-deploy/env_template:ro" \
  "$generator_image" \
  bundle exec ruby -rsecurerandom -rweb-push -e '
    hostname_pattern = /\A[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\z/
    email_pattern = /\A[^\s@]+@[^\s@]+\.[^\s@]+\z/
    template_path, hostname, email = ARGV
    abort "hostname must be a fully qualified domain name" if hostname.length > 253 || !hostname.include?(".")
    abort "hostname must be a valid fully qualified domain name" unless hostname.split(".").all? { |label| hostname_pattern.match?(label) }
    abort "email address is invalid" unless email_pattern.match?(email)

    postgres_password = SecureRandom.hex(32)
    replacements = {
      "REPLACE_WITH_HOSTNAME" => hostname.downcase,
      "REPLACE_WITH_CONTACT_EMAIL" => email,
      "REPLACE_WITH_POSTGRES_PASSWORD" => postgres_password,
      "REPLACE_WITH_DEVISE_SECRET" => SecureRandom.hex(32),
      "REPLACE_WITH_SECRET_COOKIE_TOKEN" => SecureRandom.hex(32),
      "REPLACE_WITH_RAILS_INBOUND_EMAIL_PASSWORD" => SecureRandom.hex(32)
    }
    content = File.read(template_path)
    replacements.each { |placeholder, value| content.gsub!(placeholder, value) }
    remaining = content.scan(/REPLACE_WITH_[A-Z_]+/).uniq.sort
    abort "unhandled placeholders: #{remaining.join(", ")}" if remaining.any?

    vapid_key = WebPush.generate_key
    content = content.chomp + "\n\n# Browser push notifications\n"
    content << "VAPID_PUBLIC_KEY=#{vapid_key.public_key}\n"
    content << "VAPID_PRIVATE_KEY=#{vapid_key.private_key}\n"
    content << "VAPID_SUBJECT=mailto:#{email}\n"
    STDOUT.write(content)
  ' /opt/loomio-deploy/env_template "$hostname" "$support_email" > "$generated_file"

if grep -q 'REPLACE_WITH_' "$generated_file"; then
  echo "The generated environment contains an unresolved placeholder; no changes were made" >&2
  exit 1
fi
for setting in POSTGRES_PASSWORD DATABASE_URL DEVISE_SECRET SECRET_COOKIE_TOKEN RAILS_INBOUND_EMAIL_PASSWORD VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY VAPID_SUBJECT; do
  if [ "$(grep -c "^${setting}=" "$generated_file")" -ne 1 ]; then
    echo "The generated environment does not contain exactly one $setting; no changes were made" >&2
    exit 1
  fi
done

chmod 600 "$generated_file"
mv "$generated_file" "$env_file"
created=true

echo "Created $env_file for $hostname"
