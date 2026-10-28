# Security review instructions

## Security review

- Treat voting, anonymous polls, permissions, authentication, and sessions as high-risk parts of Loomio. Changes touching these areas require an explicit security review and focused regression tests. Conduct the review directly unless the user explicitly requests a security-review plugin or tool.
- For anonymous polls, review the complete data flow rather than only the primary serializer. Check API responses, nested serializers, events and timelines, search indexes, live updates, notifications, mailers, CSV/JSON exports, backups, and background jobs.
- Review each access boundary separately: signed-out/public users, ordinary members, poll participants, thread admins, group admins, instance admins, and operators with database or backup access. Do not assume that authorization at one endpoint protects related endpoints or exports.
- Test both direct disclosure and composition attacks. Individually harmless endpoints can reveal sensitive information when records are joined by IDs, timestamps, ordering, or shared events.
- Exercise permission failures as well as successful paths. Include public/private groups, direct and group topics, active and closed polls, each `hide_results` mode, anonymous and identified polls, quorum behavior, and administrator-only feature flags.
- Use and curate the reusable access-control fixture matrix rooted at `topics(:discussion_topic)` and `topics(:direct_topic)`. Its named roles represent current members, topic guests, members of `alien_group`, non-guest readers, revoked access, inactive users, and conflicting account/membership/topic preferences. Extend the fixture matrix whenever a new access boundary or preference source is introduced; do not replace matrix coverage with isolated ad hoc records.
- Review session security when changing authentication or authorization: session creation, rotation, expiry, revocation, logout, impersonation, CSRF protection, token scope, cookie flags, and cleanup of dependent session records.
- Prefer defense in depth at storage and shared serialization boundaries. Avoid relying only on UI hiding, closing-time mutation, or one controller guard to protect sensitive data.
