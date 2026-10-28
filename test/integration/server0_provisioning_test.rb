require 'test_helper'

class Server0ProvisioningTest < ActionDispatch::IntegrationTest
  setup do
    @original_key = ENV['SERVER_API_KEY']
    @original_legacy_key = ENV.delete('B3_API_KEY')
    ENV['SERVER_API_KEY'] = SecureRandom.hex(32)
    @headers = { 'Authorization' => "Bearer #{ENV.fetch('SERVER_API_KEY')}" }
    @group = groups(:group)
    @membership = memberships(:member_normal_membership)
  end

  teardown do
    @original_key.nil? ? ENV.delete('SERVER_API_KEY') : ENV['SERVER_API_KEY'] = @original_key
    @original_legacy_key.nil? ? ENV.delete('B3_API_KEY') : ENV['B3_API_KEY'] = @original_legacy_key
    Current.reset
  end

  test 'server key lists private and public groups across the instance with bounded pagination' do
    groups(:alien_group).discard!
    expected = Group.kept.order(:id).pluck(:id)
    get '/api/server0/groups', params: { limit: 2, offset: 1 }, headers: @headers
    assert_response :success
    assert_equal expected.drop(1).take(2), json.fetch('groups').pluck('id')
    assert_equal expected.size, json.dig('meta', 'total')
    assert_equal %w[group_privacy handle id key name parent_id], json.fetch('groups').first.keys.sort

    get '/api/server0/groups', params: { limit: 100_000 }, headers: @headers
    assert_response :success
    assert_operator json.fetch('groups').size, :<=, 50
    [ groups(:public_group), @group ].each do |group|
      assert_includes expected, group.id
    end
  end

  test 'server membership listing includes roles and pending state but no credentials or voting data' do
    pending = Membership.create!(group: @group, user: users(:alien))
    @membership.update!(delegate: true)
    get '/api/server0/memberships', params: { group_id: @group.id, limit: 100_000 }, headers: @headers
    assert_response :success
    rows = json.fetch('memberships')
    member = rows.find { |row| row['id'] == @membership.id }
    assert_equal @membership.user.email, member.fetch('user_email')
    assert_equal true, member.fetch('delegate')
    assert_equal false, member.fetch('pending')
    assert_equal true, rows.find { |row| row['id'] == pending.id }.fetch('pending')
    assert_equal @group.memberships.count, json.dig('meta', 'total')
    assert_equal %w[accepted_at admin delegate group_id id pending user_email user_id user_name], member.keys.sort
    assert_equal rows.pluck('id').sort, rows.pluck('id')

    get '/api/server0/memberships', params: { group_id: @group.id, limit: 1, offset: 1 }, headers: @headers
    assert_equal [ rows[1]['id'] ], json.fetch('memberships').pluck('id')
  end

  test 'adding emails creates pending invitations without a bot and is idempotent' do
    email = 'new-server-member@example.org'
    assert_difference [ 'User.count', 'Membership.count', 'Notification.count' ], 1 do
      post '/api/server0/memberships', params: { group_id: @group.id, emails: [ " #{email.upcase} ", email ] }, headers: @headers, as: :json
    end
    assert_response :success
    assert_equal [ email ], json.fetch('added_emails')
    assert_empty json.fetch('removed_emails')
    membership = @group.memberships.find_by!(user: User.find_by!(email: email))
    assert_nil membership.inviter_id
    assert_nil membership.accepted_at
    refute membership.user.email_verified?
    notification = Notification.order(:id).last
    assert_equal 'membership_created', notification.kind
    assert_nil notification.actor_id
    assert_includes notification.recipient_user_ids, membership.user_id
    deliveries = NotificationDeliveryRouter.for(notification).route!
    email_delivery = deliveries.find { |delivery| delivery.channel == 'email' }
    assert_not_nil email_delivery
    assert_nothing_raised { NotificationMailer.notification(email_delivery.id).message }

    assert_no_difference [ 'User.count', 'Membership.count', 'Notification.count' ] do
      post '/api/server0/memberships', params: { group_id: @group.id, emails: [ email ] }, headers: @headers, as: :json
    end
    assert_response :success
    assert_empty json.fetch('added_emails')
  end

  test 'verified existing organization members are accepted when invited to a subgroup' do
    user = users(:member_normal)
    post '/api/server0/memberships', params: { group_id: groups(:subgroup).id, emails: [ user.email ] }, headers: @headers, as: :json
    assert_response :success
    assert_not_nil groups(:subgroup).membership_for(user).accepted_at
  end

  test 'explicit sync revokes absent members while omitted or false remove_absent only adds' do
    [ nil, false, 'false', 0, '0' ].each do |flag|
      payload = { group_id: @group.id, emails: [] }
      payload[:remove_absent] = flag unless flag.nil?
      post '/api/server0/memberships', params: payload, headers: @headers, as: :json
      assert_response :success
      assert_nil @membership.reload.revoked_at
      assert_empty json.fetch('removed_emails')
    end

    post '/api/server0/memberships', params: { group_id: @group.id, emails: [], remove_absent: true }, headers: @headers, as: :json
    assert_response :success
    assert_not_nil @membership.reload.revoked_at
    assert_includes json.fetch('removed_emails'), @membership.user.email
    assert_empty @group.memberships
  end

  test 'malformed sync inputs cannot add accounts or remove memberships' do
    payloads = [
      { remove_absent: true },
      { emails: nil, remove_absent: true },
      { emails: 'one@example.org', remove_absent: true },
      { emails: [ nil ], remove_absent: true },
      { emails: [ 'valid@example.org', 'broken' ], remove_absent: true },
      { emails: [ 'valid@example.org' ], remove_absent: 'yes' }
    ]
    payloads.each do |payload|
      assert_no_difference [ 'User.count', 'Membership.count', 'Notification.count' ] do
        post '/api/server0/memberships', params: { group_id: @group.id, **payload }, headers: @headers, as: :json
      end
      assert_response :bad_request
      assert_nil @membership.reload.revoked_at
    end
  end

  test 'deactivated accounts are rejected without implicitly reactivating them' do
    user = users(:inactive_member_loud)
    post '/api/server0/memberships', params: { group_id: @group.id, emails: [ 'new-before-inactive@example.org', user.email ], remove_absent: true }, headers: @headers, as: :json
    assert_response :unprocessable_entity
    refute User.exists?(email: 'new-before-inactive@example.org')
    assert_not_nil user.reload.deactivated_at
    assert_nil @membership.reload.revoked_at
  end

  test 'server removal revokes subgroup membership topic access and active poll stances' do
    user = users(:member_normal)
    MembershipService.add_member(group: groups(:subgroup), user: user)
    reader = TopicReader.for(user: user, topic: topics(:discussion_topic))
    reader.update!(guest: true)
    direct_reader = TopicReader.for(user: user, topic: topics(:direct_topic))
    direct_reader.update!(guest: true)
    poll = create_poll
    stance = poll.stances.latest.find_by!(participant: user)
    unrelated = groups(:alien_group).add_member!(user)

    delete "/api/server0/memberships/#{@membership.id}", headers: @headers
    assert_response :success
    assert_not_nil @membership.reload.revoked_at
    assert_nil @membership.revoker_id
    assert_not_nil Membership.find_by!(group: groups(:subgroup), user: user).revoked_at
    assert_not_nil reader.reload.revoked_at
    refute reader.guest?
    assert_not_nil stance.reload.revoked_at
    assert_nil unrelated.reload.revoked_at
    assert_nil direct_reader.reload.revoked_at
    assert direct_reader.guest?
    refute user.can?(:vote_in, poll)

    delete "/api/server0/memberships/#{@membership.id}", headers: @headers
    assert_response :success
  end

  test 'reinviting restores revoked access and voting without restoring administrator status' do
    user = @membership.user
    @membership.update!(admin: true)
    poll = create_poll
    stance = poll.stances.latest.find_by!(participant: user)
    reader = TopicReader.for(user: user, topic: topics(:discussion_topic))
    reader.save!
    delete "/api/server0/memberships/#{@membership.id}", headers: @headers
    assert_response :success

    post '/api/server0/memberships', params: { group_id: @group.id, emails: [ user.email ] }, headers: @headers, as: :json
    assert_response :success
    assert_nil @membership.reload.revoked_at
    refute @membership.admin?
    assert_nil stance.reload.revoked_at
    assert_nil reader.reload.revoked_at
    assert user.can?(:vote_in, poll)
  end

  test 'role updates maintain counts delegate profiles and transition notifications' do
    before = @group.reload.admin_memberships_count
    assert_difference 'Notification.count', 2 do
      patch "/api/server0/memberships/#{@membership.id}", params: { membership: { admin: true, delegate: true } }, headers: @headers, as: :json
    end
    assert_response :success
    assert_equal true, json.dig('membership', 'admin')
    assert_equal true, json.dig('membership', 'delegate')
    assert_equal before + 1, @group.reload.admin_memberships_count
    assert_equal true, @membership.user.reload.experiences.dig('delegates', @group.id.to_s)
    assert_no_difference 'Notification.count' do
      patch "/api/server0/memberships/#{@membership.id}", params: { membership: { admin: true, delegate: true } }, headers: @headers, as: :json
    end
    assert_response :success

    patch "/api/server0/memberships/#{@membership.id}", params: { membership: { admin: false, delegate: false } }, headers: @headers, as: :json
    assert_response :success
    refute @membership.reload.admin?
    refute @membership.delegate?
    assert_nil @membership.user.reload.experiences.dig('delegates', @group.id.to_s)
    assert_equal before, @group.reload.admin_memberships_count
  end

  test 'role updates reject unknown fields invalid booleans and revoked memberships' do
    [ { admin: 'yes' }, { user_id: users(:alien).id }, { accepted_at: Time.current }, { admin: true, weight: 100 } ].each do |attributes|
      patch "/api/server0/memberships/#{@membership.id}", params: { membership: attributes }, headers: @headers, as: :json
      assert_response :bad_request
      refute @membership.reload.admin?
    end
    delete "/api/server0/memberships/#{@membership.id}", headers: @headers
    patch "/api/server0/memberships/#{@membership.id}", params: { membership: { admin: true } }, headers: @headers, as: :json
    assert_response :not_found
  end

  test 'server creates accounts and rejects duplicate invalid and unsupported fields' do
    email = 'server-provisioned@example.org'
    assert_difference 'User.count', 1 do
      post '/api/server0/users', params: { user: { email: " #{email.upcase} ", name: 'Alex Example', username: 'alexprovisioned', is_admin: false } }, headers: @headers, as: :json
    end
    assert_response :created
    assert_equal email, json.dig('user', 'email')
    refute User.find(json.dig('user', 'id')).email_verified?
    refute_includes response.body, 'api_key'

    assert_no_difference 'User.count' do
      post '/api/server0/users', params: { user: { email: email } }, headers: @headers, as: :json
      assert_response :unprocessable_entity
      post '/api/server0/users', params: { user: { email: 'broken' } }, headers: @headers, as: :json
      assert_response :unprocessable_entity
      post '/api/server0/users', params: { user: { email: 'unknown-fields@example.org', email_verified: true } }, headers: @headers, as: :json
      assert_response :bad_request
    end
  end

  test 'all provisioning endpoints reject missing malformed query body and user credentials' do
    endpoints = [
      [ :get, '/api/server0/groups', {} ],
      [ :get, '/api/server0/memberships', { group_id: @group.id } ],
      [ :post, '/api/server0/memberships', { group_id: @group.id, emails: [], remove_absent: true } ],
      [ :patch, "/api/server0/memberships/#{@membership.id}", { membership: { admin: true } } ],
      [ :delete, "/api/server0/memberships/#{@membership.id}", {} ],
      [ :post, '/api/server0/users', { user: { email: 'unauthorized@example.org' } } ]
    ]
    roles = %i[admin member_normal guest_normal alien former_member_loud inactive_member_loud]
    credentials = [ nil, 'Bearer wrong', "Basic #{ENV.fetch('SERVER_API_KEY')}" ] + roles.map { |role| "Bearer #{users(role).api_key}" }
    endpoints.each do |method, path, payload|
      credentials.each do |credential|
        public_send(method, path, params: payload.merge(b3_api_key: ENV.fetch('SERVER_API_KEY')), headers: { 'Authorization' => credential }, as: :json)
        assert_response :forbidden
      end
    end
    assert_nil @membership.reload.revoked_at
    refute @membership.admin?
    refute User.exists?(email: 'unauthorized@example.org')
  end

  test 'an instance administrator browser session does not authenticate server operations' do
    administrator = users(:admin)
    administrator.update!(is_admin: true, password: 'server-api-session-test')
    post '/api/v1/sessions', params: { user: { email: administrator.email, password: 'server-api-session-test' } }, as: :json
    assert_response :success
    get '/api/server0/groups'
    assert_response :forbidden
    post '/api/server0/memberships', params: { group_id: @group.id, emails: [], remove_absent: true }, as: :json
    assert_response :forbidden
    assert_nil @membership.reload.revoked_at
  end

  test 'disabled server credentials and inactive groups cannot provision memberships' do
    [ nil, '', 'k' * 16 ].each do |key|
      key.nil? ? ENV.delete('SERVER_API_KEY') : ENV['SERVER_API_KEY'] = key
      post '/api/server0/memberships', params: { group_id: @group.id, emails: [ 'disabled@example.org' ] }, headers: { 'Authorization' => "Bearer #{key}" }, as: :json
      assert_response :forbidden
    end
    ENV['SERVER_API_KEY'] = @headers.fetch('Authorization').delete_prefix('Bearer ')
    @group.discard!
    post '/api/server0/memberships', params: { group_id: @group.id, emails: [ 'disabled@example.org' ] }, headers: @headers, as: :json
    assert_response :not_found
    refute User.exists?(email: 'disabled@example.org')
  end

  test 'the legacy b3 path and B3_API_KEY still authenticate server operations' do
    get '/api/b3/groups', headers: @headers
    assert_response :success

    legacy_key = SecureRandom.hex(32)
    ENV.delete('SERVER_API_KEY')
    ENV['B3_API_KEY'] = legacy_key
    get '/api/server0/groups', headers: { 'Authorization' => "Bearer #{legacy_key}" }
    assert_response :success

    ENV['SERVER_API_KEY'] = SecureRandom.hex(32)
    get '/api/server0/groups', headers: { 'Authorization' => "Bearer #{legacy_key}" }
    assert_response :forbidden
    get '/api/b3/groups', headers: { 'Authorization' => "Bearer #{legacy_key}" }
    assert_response :forbidden
  end

  private

  def json
    response.parsed_body
  end

  def create_poll
    PollService.create(params: {
      title: 'Provisioning access', poll_type: 'poll', group_id: @group.id,
      poll_option_names: %w[Yes No], closing_at: 3.days.from_now
    }, actor: users(:admin))
  end
end
