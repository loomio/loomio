require 'test_helper'

class CollabDocumentAuthServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @discussion = discussions(:discussion)
    hex = SecureRandom.hex(4)
    other_user = User.create!(name: "other#{hex}", email: "other#{hex}@example.com", username: "other#{hex}", email_verified: true)
    other_group = Group.create!(name: "collabother#{hex}", handle: "collabother#{hex}", group_privacy: 'secret')
    other_group.add_admin!(other_user)
    @other_discussion = DiscussionService.create(params: { title: "Other #{hex}", group_id: other_group.id }, actor: other_user)
    ActionMailer::Base.deliveries.clear
  end

  test "signed-out visitors may only edit a new group" do
    assert authorized?(nil, "group-new-0-1-1")
    refute authorized?(nil, "discussion-new-#{@user.id}-1")
    refute authorized?(nil, "group-#{@discussion.group_id}-description")
    refute authorized?(nil, "discussion-#{@discussion.id}-description")
  end

  test "users may edit their own new records only" do
    assert authorized?(@user, "comment-new-#{@user.id}-1-1-1")
    refute authorized?(@user, "comment-new-#{@user.id}1-1-1-1")
  end

  test "users may edit existing records they can update" do
    assert authorized?(@user, "discussion-#{@discussion.id}-description")
    refute authorized?(@user, "discussion-#{@other_discussion.id}-description")
    refute authorized?(@user, "discussion-0-description")
  end

  test "unsupported document types are denied" do
    refute authorized?(nil, "membership-new-0")
    refute authorized?(@user, "membership-new-#{@user.id}")
    refute authorized?(@user, "")
  end

  test "identifies the active user of the session cookie" do
    session_record = @user.sessions.create!(user_agent: 'test', ip_address: '127.0.0.1')
    assert_equal @user, CollabDocumentAuthService.user_from_session(env_with_session(session_record.id))

    assert_nil CollabDocumentAuthService.user_from_session(ActionDispatch::TestRequest.create.env)
    assert_nil CollabDocumentAuthService.user_from_session(env_with_session(0))

    @user.update!(deactivated_at: Time.current)
    assert_nil CollabDocumentAuthService.user_from_session(env_with_session(session_record.id))
  end

  test "a signed-out session cannot open records after logout" do
    session_record = @user.sessions.create!(user_agent: 'test', ip_address: '127.0.0.1')
    env = env_with_session(session_record.id)
    assert CollabServer.config.authenticate.call(document_name: "discussion-#{@discussion.id}-description", env: env)

    session_record.revoke!
    refute CollabServer.config.authenticate.call(document_name: "discussion-#{@discussion.id}-description", env: env)
    assert CollabServer.config.authenticate.call(document_name: "group-new-0-1", env: env)
  end

  test "only pages from this host may connect" do
    allowed = CollabServer.config.allowed_origin
    assert allowed.call("https://#{ENV['CANONICAL_HOST']}")
    assert allowed.call("http://localhost:8080")
    refute allowed.call("https://#{ENV['CANONICAL_HOST']}.evil.example")
    refute allowed.call("https://evil.example")
    refute allowed.call(nil)
    refute allowed.call("not a url")
  end

  private

  def authorized?(user, document_name)
    CollabDocumentAuthService.authorized?(user: user, document_name: document_name)
  end

  def env_with_session(session_id)
    request = ActionDispatch::TestRequest.create
    request.cookie_jar.signed[:session_id] = session_id
    request.env
  end
end
