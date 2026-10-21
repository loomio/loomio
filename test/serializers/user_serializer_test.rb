require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  test 'only instance administrators receive suppression status and no evidence is serialized' do
    user = users(:member_normal)
    record = EmailSuppressionService.record!(email: user.email, reason: 'complaint', source_key: 'private-feedback-source')
    [ nil, users(:member_normal), users(:alien) ].each do |viewer|
      payload = serialize(user, viewer)
      refute payload.key?(:email_delivery_blocked)
      refute payload.key?(:email_suppressions)
      refute_includes payload.to_json, record.email_sha256
      refute_includes payload.to_json, record.source_key
    end
    payload = serialize(user, users(:admin))
    assert_equal true, payload.fetch(:email_delivery_blocked)
    refute payload.key?(:bounces_count)
    refute payload.key?(:complaints_count)
    refute_includes payload.to_json, record.email_sha256
  end

  test 'administrator lists batch suppression lookups and ordinary lists do not query them' do
    users = User.where(id: [ users(:member_normal).id, users(:member).id ]).to_a
    EmailSuppressionService.record!(email: users.first.email, reason: 'complaint', source_key: 'test:batched')
    cache = RecordCache.for_collection(users, users(:admin).id)
    queries = []
    callback = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] if payload[:sql].include?('email_suppressions') }
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      users.each { |user| serialize(user, users(:member), cache) }
      assert_empty queries
      payloads = users.map { |user| serialize(user, users(:admin), cache) }
      assert_equal [ true, false ], payloads.map { |payload| payload.fetch(:email_delivery_blocked) }
      assert_equal 1, queries.size, queries.join("\n")
    end
  end

  private

  def serialize(user, viewer, cache = nil)
    scope = { current_user_id: viewer&.id, include_email_delivery_status: !!viewer&.is_admin?, exclude_types: [] }
    scope[:cache] = cache if cache
    UserSerializer.new(user, scope: scope).as_json.fetch(:user)
  end
end
