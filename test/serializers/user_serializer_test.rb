require 'test_helper'

class UserSerializerTest < ActiveSupport::TestCase
  test 'default avatars expose no Gravatar URL or email hash to any viewer' do
    user = users(:member_normal)
    hash = Digest::MD5.hexdigest(user.email.downcase)

    [nil, user, users(:alien), users(:admin)].each do |viewer|
      payload = serialize(user, viewer)
      assert_nil payload[:thumb_url]
      assert_nil payload[:avatar_url]
      refute_includes payload.to_json, 'gravatar.com'
      refute_includes payload.to_json, hash
    end
  end

  test 'suppression status and evidence stay out of user payloads for every viewer' do
    user = users(:member_normal)
    record = EmailSuppressionService.record!(email: user.email, reason: 'complaint', source_key: 'private-feedback-source')
    queries = []
    callback = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] if payload[:sql].include?('email_suppressions') }

    [nil, user, users(:alien), users(:admin)].each do |viewer|
      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
        payload = serialize(user, viewer)
        %i[email_delivery_blocked email_suppressions bounces_count complaints_count].each do |key|
          refute payload.key?(key)
        end
        refute_includes payload.to_json, record.email_sha256
        refute_includes payload.to_json, record.source_key
      end
    end
    assert_empty queries
  end

  private

  def serialize(user, viewer)
    scope = { current_user_id: viewer&.id, exclude_types: [] }
    UserSerializer.new(user, scope: scope).as_json.fetch(:user)
  end
end
