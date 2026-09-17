require 'test_helper'

class Api::B2::MembershipsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @admin = User.create!(name: "admin#{hex}", email: "admin#{hex}@example.com", username: "admin#{hex}", email_verified: true)
    @group = Group.new(name: "b2membgroup#{hex}", group_privacy: 'secret')
    @group.creator = @admin
    @group.save!
    @group.add_admin!(@admin)
    @admin.update_columns(api_key: "apikey#{SecureRandom.hex(8)}")
    ActionMailer::Base.deliveries.clear
  end

  test "index serializes the filtered collection" do
    @request.headers['Authorization'] = "Bearer #{@admin.api_key}"
    get :index, params: { group_id: @group.id }

    assert_response :success
    membership_ids = JSON.parse(response.body).fetch('memberships').pluck('id')
    assert_includes membership_ids, @group.membership_for(@admin).id
  end

  test "group member can list names and roles without other members' email addresses" do
    member = create_user_with_api_key!("member")
    other_member = create_user_with_api_key!("other")
    @group.add_member!(member)
    @group.add_member!(other_member).update!(delegate: true, title: "Facilitator")

    @request.headers['Authorization'] = "Bearer #{member.api_key}"
    get :index, params: { group_id: @group.id }

    assert_response :success
    serialized_user = json.fetch("users").find { |user| user.fetch("id") == other_member.id }
    serialized_membership = json.fetch("memberships").find { |membership| membership.fetch("user_id") == other_member.id }
    assert_equal other_member.name, serialized_user.fetch("name")
    refute serialized_user.key?("email")
    assert_equal true, serialized_membership.fetch("delegate")
    assert_equal "Facilitator", serialized_membership.fetch("title")
    refute serialized_membership.key?("user_email")
  end

  test "group admin can list member email addresses" do
    member = create_user_with_api_key!("member")
    @group.add_member!(member)

    @request.headers['Authorization'] = "Bearer #{@admin.api_key}"
    get :index, params: { group_id: @group.id }

    assert_response :success
    serialized_user = json.fetch("users").find { |user| user.fetch("id") == member.id }
    serialized_membership = json.fetch("memberships").find { |membership| membership.fetch("user_id") == member.id }
    refute serialized_user.key?("email")
    assert_equal member.email, serialized_membership.fetch("user_email")
  end

  test "non-member cannot list a private group's memberships" do
    outsider = create_user_with_api_key!("outsider")

    @request.headers['Authorization'] = "Bearer #{outsider.api_key}"
    get :index, params: { group_id: @group.id }

    assert_response :success
    assert_empty json.fetch("memberships")
    assert_empty json.fetch("users", [])
  end

  test "adds members to group" do
    post :create, params: {
      group_id: @group.id,
      emails: ['hey@there.com'],
      api_key: @admin.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    assert_equal ['hey@there.com'], json['added_emails']
    assert_equal [], json['removed_emails']
  end

  test "removes members from group" do
    post :create, params: {
      group_id: @group.id,
      remove_absent: 1,
      emails: ['hey@there.com'],
      api_key: @admin.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    assert_equal ['hey@there.com'], json['added_emails']
    assert_equal [@admin.email], json['removed_emails']
  end

  test "user is not admin" do
    hex = SecureRandom.hex(4)
    member = User.create!(name: "member#{hex}", email: "member#{hex}@example.com", username: "member#{hex}", email_verified: true)
    member.update_columns(api_key: "memberkey#{SecureRandom.hex(8)}")
    @group.add_member!(member)
    post :create, params: {
      group_id: @group.id,
      emails: ['hey@there.com'],
      api_key: member.api_key
    }
    assert_response 403
  end

  test "bad group id" do
    bad_group = groups(:alien_group)
    post :create, params: {
      group_id: bad_group.id,
      emails: ['hey@there.com'],
      api_key: @admin.api_key
    }
    assert_response 403
  end

  test "missing group id" do
    post :create, params: {
      emails: ['hey@there.com'],
      api_key: @admin.api_key
    }
    assert_response 404
  end

  test "missing api_key" do
    post :create, params: {
      group_id: @group.id,
      emails: ['hey@there.com']
    }
    assert_response 403
  end

  test "bad api_key" do
    post :create, params: {
      group_id: @group.id,
      emails: ['hey@there.com'],
      api_key: 123
    }
    assert_response 403
  end

  test "global admin not in group can add members" do
    new_admin = users(:admin)
    new_admin.update_columns(api_key: "gadminkey#{SecureRandom.hex(8)}")
    post :create, params: {
      group_id: @group.id,
      emails: ['hi@there.com'],
      api_key: new_admin.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    assert_equal ['hi@there.com'], json['added_emails']
    assert_equal [], json['removed_emails']
  end

  test "global admin not in group can remove members" do
    new_admin = users(:admin)
    new_admin.update_columns(api_key: "gadminkey#{SecureRandom.hex(8)}")
    post :create, params: {
      group_id: @group.id,
      remove_absent: 1,
      emails: ['hey@there.com'],
      api_key: new_admin.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    assert_equal ['hey@there.com'], json['added_emails']
    assert_equal [@admin.email], json['removed_emails']
  end

  test "non-global-admin not in group cannot add members" do
    hex = SecureRandom.hex(4)
    new_user = User.create!(name: "rando#{hex}", email: "rando#{hex}@example.com", username: "rando#{hex}", email_verified: true)
    new_user.update_columns(api_key: "randokey#{SecureRandom.hex(8)}")
    post :create, params: {
      group_id: @group.id,
      emails: ['hi@there.com'],
      api_key: new_user.api_key
    }
    assert_response 403
  end

  private

  def create_user_with_api_key!(prefix)
    hex = SecureRandom.hex(4)
    User.create!(
      name: "#{prefix}#{hex}",
      email: "#{prefix}#{hex}@example.com",
      username: "#{prefix}#{hex}",
      email_verified: true
    ).tap do |user|
      user.update_columns(api_key: "#{prefix}key#{SecureRandom.hex(8)}")
    end
  end

  def json
    JSON.parse(response.body)
  end
end
