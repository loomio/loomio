## User API keys now follow group permissions for instance administrators

The User API now applies the same group membership and group-administrator requirements to every API-key user. Instance-administrator status no longer grants an API key access to private groups, private topics, membership management, member email addresses, or instance-wide participation reports. Instance-level integrations should use the Server API.
