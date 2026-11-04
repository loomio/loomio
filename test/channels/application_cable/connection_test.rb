require "test_helper"
require "action_cable/connection/test_case"
require_relative "../../support/access_volume_matrix"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  tests ApplicationCable::Connection

  test "active accounts connect through their session regardless of topic membership" do
    roles = AccessVolumeMatrix::ROLES - %i[inactive_member_loud inactive_guest_loud]
    (roles + [:server_admin]).each do |role|
      user = users(role)
      cookies.signed[:session_id] = user.sessions.create!(user_agent: "Cable test", ip_address: "127.0.0.1").id

      connect

      assert_equal user.id, connection.current_user.id, role.to_s
    end
  end

  test "missing sessions cannot connect using API credentials or a claimed account ID" do
    user = users(:member_normal)

    assert_reject_connection do
      connect params: { user_id: user.id, api_key: user.api_key }, headers: { "Authorization" => "Bearer #{user.api_key}" }
    end
  end

  test "a plain session cookie does not authenticate a connection" do
    session_record = users(:member_normal).sessions.create!(user_agent: "Cable test", ip_address: "127.0.0.1")
    cookies[:session_id] = session_record.id

    assert_reject_connection { connect }
  end

  test "unknown and revoked session cookies cannot connect" do
    session_record = users(:member_normal).sessions.create!(user_agent: "Cable test", ip_address: "127.0.0.1")
    session_record.destroy!
    [session_record.id, Session.maximum(:id).to_i + 1].each do |session_id|
      cookies.signed[:session_id] = session_id

      assert_reject_connection { connect }
    end
  end

  test "deactivated members and guests cannot connect with an existing session" do
    %i[inactive_member_loud inactive_guest_loud].each do |role|
      cookies.signed[:session_id] = users(role).sessions.create!(user_agent: "Cable test", ip_address: "127.0.0.1").id

      assert_reject_connection { connect }
    end
  end
end
