# Be sure to restart your server when you modify this file.

# Configure Rails to trust certain IPs as proxies, so it can extract the client IP correctly
# from X-Forwarded-For headers when requests pass through proxies like nginx, load balancers, or Docker.

# Docker network ranges
docker_networks = %w[
  172.16.0.0/12
  192.168.0.0/16
  10.0.0.0/8
]

# Add any other proxies you might have (e.g., load balancers, CDNs)
other_proxies = ENV.fetch('TRUSTED_PROXIES', '').split(',').map(&:strip)

# Combine all trusted proxy IPs
trusted_proxies = docker_networks + other_proxies

Rails.application.config.middleware.insert_before(0, ActionDispatch::RemoteIp, proxies: trusted_proxies) 