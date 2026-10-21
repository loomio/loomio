require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  test 'suppression status requires explicit preloading and never includes its evidence' do
    user = users(:member_normal)
    record = EmailSuppressionService.record!(email: user.email, reason: 'complaint', source_key: 'private-feedback-source')
    [ nil, users(:member_normal), users(:alien), users(:admin) ].each do |viewer|
      payload = serialize(user, viewer)
      refute payload.key?(:email_delivery_blocked)
      refute payload.key?(:email_suppressions)
      refute_includes payload.to_json, record.email_sha256
      refute_includes payload.to_json, record.source_key
    end
    payload = serialize(user, users(:admin), blocked_user_ids: Set[user.id])
    assert_equal true, payload.fetch(:email_delivery_blocked)
    refute payload.key?(:bounces_count)
    refute payload.key?(:complaints_count)
    refute_includes payload.to_json, record.email_sha256
  end

  test 'preloaded suppression results serialize without querying the database' do
    users = User.where(id: [ users(:member_normal).id, users(:member).id ]).to_a
    EmailSuppressionService.record!(email: users.first.email, reason: 'complaint', source_key: 'test:batched')
    blocked_user_ids = EmailSuppression.blocked_user_ids(users)
    queries = []
    callback = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] if payload[:sql].include?('email_suppressions') }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      payloads = users.map { |user| serialize(user, users(:admin), blocked_user_ids: blocked_user_ids) }
      assert_equal [ true, false ], payloads.map { |payload| payload.fetch(:email_delivery_blocked) }
      assert_empty queries
    end
  end

  private

  def serialize(user, viewer, blocked_user_ids: nil)
    scope = { current_user_id: viewer&.id, exclude_types: [] }
    scope[:email_delivery_blocked_user_ids] = blocked_user_ids if blocked_user_ids
    UserSerializer.new(user, scope: scope).as_json.fetch(:user)
  end
end
