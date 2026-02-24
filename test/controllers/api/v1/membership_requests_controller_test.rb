require 'test_helper'

class Api::V1::MembershipRequestsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @group.update(members_can_add_members: true)
    @group.add_member! @user unless @group.members.include?(@user)

    @other_group = Group.create!(
      name: "Other Group",
      handle: "other-group"
    )

    # Create requestor users for membership requests
    @pending_requestor = User.create!(
      name: "Pending User",
      username: "pendingreq",
      email: "pending@example.com"
    )

    @other_pending_requestor = User.create!(
      name: "Other Pending",
      username: "otherpendingreq",
      email: "otherpending@example.com"
    )

    @approved_requestor = User.create!(
      name: "Approved User",
      username: "approvedreq",
      email: "approved@example.com"
    )

    @pending_request = MembershipRequest.create!(
      requestor: @pending_requestor,
      group: @group
    )

    @other_pending_request = MembershipRequest.create!(
      requestor: @other_pending_requestor,
      group: @other_group
    )

    @approved_request = MembershipRequest.create!(
      requestor: @approved_requestor,
      group: @group
    )
    @approved_request.approve!(@user)

    sign_in @user
  end

  test "pending returns membership requests filtered by group when permitted" do
    get :pending, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_includes json.keys, 'membership_requests'
    assert_equal @pending_request.id, json['membership_requests'].first['id']
  end

  test "pending returns access denied when not permitted" do
    @group.update_attribute(:members_can_add_members, false)

    get :pending, params: { group_id: @group.id }
    assert_response :forbidden
    assert_includes JSON.parse(response.body)['exception'], 'CanCan::AccessDenied'
  end

  test "previous returns approved membership requests filtered by group when permitted" do
    get :previous, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_includes json.keys, 'membership_requests'
    assert_equal @approved_request.id, json['membership_requests'].first['id']
  end

  test "previous returns access denied when not permitted" do
    @group.update_attribute(:members_can_add_members, false)

    get :previous, params: { group_id: @group.id }
    assert_response :forbidden
    assert_includes JSON.parse(response.body)['exception'], 'CanCan::AccessDenied'
  end

  test "approve membership request when permitted" do
    post :approve, params: { id: @pending_request.id }
    assert_response :success

    record = JSON.parse(response.body)['membership_requests'].first
    assert_equal @user.id, record['responder_id']
    assert_equal 'approved', record['response']
  end

  test "approve raises access denied when not permitted" do
    post :approve, params: { id: @other_pending_request.id }
    assert_response :forbidden
    assert_includes JSON.parse(response.body)['exception'], 'CanCan::AccessDenied'
  end

  test "ignore membership request when permitted" do
    post :ignore, params: { id: @pending_request.id }
    assert_response :success

    record = JSON.parse(response.body)['membership_requests'].first
    assert_equal @user.id, record['responder_id']
    assert_equal 'ignored', record['response']
  end

  test "ignore raises access denied when not permitted" do
    post :ignore, params: { id: @other_pending_request.id }
    assert_response :forbidden
    assert_includes JSON.parse(response.body)['exception'], 'CanCan::AccessDenied'
  end
end
