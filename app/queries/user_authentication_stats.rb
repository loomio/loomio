# frozen_string_literal: true

class UserAuthenticationStats
  # Aggregate once per user, including people with several passkeys. Latest
  # sign-in is current_sign_in_at; last_sign_in_at records the previous one.
  def self.counts(since:)
    sql = User.sanitize_sql_array([<<~SQL, { since: since }])
      SELECT COALESCE(BTRIM(users.password_digest), '') <> '' AS has_password,
             credentials.user_id IS NOT NULL AS has_passkey,
             COUNT(*) AS total,
             COUNT(*) FILTER (WHERE users.current_sign_in_at >= :since) AS recent
      FROM users
      LEFT JOIN (SELECT DISTINCT user_id FROM passkey_credentials) credentials
        ON credentials.user_id = users.id
      GROUP BY 1, 2
    SQL
    groups = User.connection.select_all(sql).to_a
    categories = {
      users: groups,
      password: groups.select { |group| group['has_password'] },
      passkey: groups.select { |group| group['has_passkey'] },
      both: groups.select { |group| group['has_password'] && group['has_passkey'] },
      neither: groups.reject { |group| group['has_password'] || group['has_passkey'] }
    }
    categories.transform_values do |category|
      { total: category.sum { |group| group['total'] }, recent: category.sum { |group| group['recent'] } }
    end
  end
end
