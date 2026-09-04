require "test_helper"

class Api::V1::Mobile::ActivityControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    @actor = users(:admin)
    @pair = authorize_device
  end

  test "lists only delivered activity the user can still access" do
    visible = create_notification(subject: discussions(:discussion), title: "Visible activity")
    hidden = create_notification(subject: discussions(:alien_discussion), title: "Hidden activity")
    undelivered = Notification.create!(actor: @actor, kind: "discussion_edited", subject: discussions(:discussion))

    get "/api/v1/mobile/activity", headers: bearer_headers

    assert_response :success
    body = JSON.parse(response.body)
    ids = body.fetch("activity").map { |item| item.fetch("id") }
    assert_includes ids, visible.id
    assert_not_includes ids, hidden.id
    assert_not_includes ids, undelivered.id
    item = body.fetch("activity").find { |record| record.fetch("id") == visible.id }
    assert_equal "Visible activity", item.fetch("title")
    assert_equal @actor.name, item.fetch("actor_name")
    assert item.fetch("url").start_with?("/")
    assert_equal false, item.fetch("viewed")
    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "supports bounded cursor pagination" do
    older = create_notification(subject: discussions(:discussion), title: "Older")
    newer = create_notification(subject: discussions(:discussion), title: "Newer")

    get "/api/v1/mobile/activity", params: { limit: 1 }, headers: bearer_headers
    assert_response :success
    first_page = JSON.parse(response.body)
    assert_equal [ newer.id ], first_page.fetch("activity").map { |item| item.fetch("id") }
    assert_equal newer.id, first_page.fetch("next_before_id")

    get "/api/v1/mobile/activity", params: { limit: 1, before_id: first_page.fetch("next_before_id") }, headers: bearer_headers
    assert_response :success
    assert_equal [ older.id ], JSON.parse(response.body).fetch("activity").map { |item| item.fetch("id") }

    get "/api/v1/mobile/activity", params: { limit: 51 }, headers: bearer_headers
    assert_response :bad_request
  end

  test "marks only this user's delivery as viewed" do
    notification = create_notification(subject: discussions(:discussion), title: "Read me")
    other_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @actor,
      channel: "in_app",
      delivered_at: Time.current
    )

    patch "/api/v1/mobile/activity/#{notification.id}", headers: bearer_headers

    assert_response :success
    assert_equal true, JSON.parse(response.body).fetch("viewed")
    assert NotificationDelivery.find_by!(notification: notification, recipient: @user, channel: "in_app").viewed?
    assert_nil other_delivery.reload.viewed_at
  end

  test "does not mark inaccessible or another user's activity" do
    hidden = create_notification(subject: discussions(:alien_discussion), title: "Hidden")
    other = Notification.create!(actor: @actor, kind: "discussion_edited", subject: discussions(:discussion))
    NotificationDelivery.create!(notification: other, recipient: @actor, channel: "in_app", delivered_at: Time.current)

    patch "/api/v1/mobile/activity/#{hidden.id}", headers: bearer_headers
    assert_response :not_found

    patch "/api/v1/mobile/activity/#{other.id}", headers: bearer_headers
    assert_response :not_found
  end

  test "requires the corresponding activity scopes" do
    notification = create_notification(subject: discussions(:discussion), title: "Scoped")
    @pair[:device].mobile_access_tokens.update_all(scopes: "activity:write")

    get "/api/v1/mobile/activity", headers: bearer_headers
    assert_response :forbidden

    @pair[:device].mobile_access_tokens.update_all(scopes: "activity:read")
    patch "/api/v1/mobile/activity/#{notification.id}", headers: bearer_headers
    assert_response :forbidden
  end

  private

  def create_notification(subject:, title:)
    notification = Notification.create!(actor: @actor, kind: "discussion_edited", subject: subject)
    NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      delivered_at: Time.current,
      translation_values: { title: title }
    )
    notification
  end

  def bearer_headers
    { "HTTP_AUTHORIZATION" => "Bearer #{@pair[:access_token]}" }
  end

  def authorize_device
    verifier = "v" * 43
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    code = Mobile::AuthenticationService.issue_authorization_code!(user: @user, code_challenge: challenge)
    Mobile::AuthenticationService.exchange_authorization_code!(
      code: code,
      code_verifier: verifier,
      client_id: Mobile::AuthenticationService::CLIENT_ID,
      redirect_uri: Mobile::AuthenticationService::REDIRECT_URI,
      device_name: "Activity Test iPhone"
    )
  end
end
