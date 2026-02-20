require 'test_helper'

class Api::V1::PollTemplatesControllerTest < ActionController::TestCase
  setup do
    @user = users(:group_admin)
    @another_user = users(:another_user)
    @group = groups(:test_group)
  end

  def create_poll_template(attrs = {})
    PollTemplate.create!({
      group: @group,
      author: @user,
      process_name: "Test Process",
      process_subtitle: "subtitle",
      poll_type: "proposal",
      default_duration_in_days: 7
    }.merge(attrs))
  end

  # === INDEX ===

  test "index returns poll templates for a group" do
    template = create_poll_template

    sign_in @user
    get :index, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    templates = json['poll_templates']
    assert templates.any? { |t| t['id'] == template.id }, "should include custom template"
  end

  test "index returns template by key_or_id" do
    template = create_poll_template

    sign_in @user
    get :index, params: { group_id: @group.id, key_or_id: template.id.to_s }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal template.id, json['poll_templates'][0]['id']
  end

  # === SHOW ===

  test "show returns a template in user group" do
    template = create_poll_template

    sign_in @user
    get :show, params: { id: template.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal template.id, json['poll_templates'][0]['id']
  end

  test "show returns errors for template not in user groups" do
    other_group = Group.create!(name: "Other #{SecureRandom.hex(4)}", creator: @another_user)
    template = create_poll_template(group: other_group, author: @another_user)

    sign_in @user
    # PollTemplate.find_by returns nil; respond_with_resource raises on nil
    assert_raises(NoMethodError) do
      get :show, params: { id: template.id }
    end
  end

  # === CREATE ===

  test "create creates a poll template as admin" do
    sign_in @user

    assert_difference 'PollTemplate.count', 1 do
      post :create, params: {
        poll_template: {
          group_id: @group.id,
          process_name: "New Poll Process",
          process_subtitle: "New subtitle",
          poll_type: "proposal",
          default_duration_in_days: 5
        }
      }
    end

    assert_response :success
    template = PollTemplate.last
    assert_equal "New Poll Process", template.process_name
    assert_equal @user.id, template.author_id
    refute template.discarded?, "admin-created template should not be auto-discarded"
  end

  test "create denies non-admin when setting disabled" do
    sign_in @another_user
    post :create, params: {
      poll_template: {
        group_id: @group.id,
        process_name: "Unauthorized",
        process_subtitle: "subtitle",
        poll_type: "proposal",
        default_duration_in_days: 7
      }
    }
    assert_response :forbidden
  end

  # === UPDATE ===

  test "update modifies a poll template as admin" do
    template = create_poll_template

    sign_in @user
    put :update, params: {
      id: template.id,
      poll_template: { process_name: "Updated Process" }
    }

    assert_response :success
    template.reload
    assert_equal "Updated Process", template.process_name
  end

  # === DESTROY ===

  test "destroy deletes a poll template as admin" do
    template = create_poll_template

    sign_in @user
    assert_difference 'PollTemplate.count', -1 do
      delete :destroy, params: { id: template.id }
    end
    assert_response :success
  end

  test "destroy denies non-admin non-author" do
    template = create_poll_template

    sign_in @another_user
    delete :destroy, params: { id: template.id }
    assert_response :forbidden
  end

  test "destroy denies non-member" do
    other_user = User.create!(name: "Outsider #{SecureRandom.hex(4)}", email: "outsider_#{SecureRandom.hex(4)}@example.com", email_verified: true)
    template = create_poll_template

    sign_in other_user
    delete :destroy, params: { id: template.id }
    assert_response :not_found
  end

  # === DISCARD / UNDISCARD ===

  test "discard discards a poll template as admin" do
    template = create_poll_template

    sign_in @user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    assert template.discarded?
  end

  test "undiscard restores a discarded poll template as admin" do
    template = create_poll_template
    template.discard!

    sign_in @user
    post :undiscard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    refute template.discarded?
  end

  test "discard denies non-admin non-author" do
    template = create_poll_template

    sign_in @another_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :forbidden
  end

  test "undiscard denies non-admin non-author" do
    template = create_poll_template
    template.discard!

    sign_in @another_user
    post :undiscard, params: { id: template.id, group_id: @group.id }
    assert_response :forbidden
  end

  test "discard denies non-member" do
    other_user = User.create!(name: "Outsider #{SecureRandom.hex(4)}", email: "outsider_#{SecureRandom.hex(4)}@example.com", email_verified: true)
    template = create_poll_template

    sign_in other_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :not_found
  end

  # === HIDE / UNHIDE (default templates) ===

  test "hide hides a default template for the group" do
    sign_in @user
    post :hide, params: { group_id: @group.id, key: "practice_proposal" }
    assert_response :success

    @group.reload
    assert_includes @group.hidden_poll_templates, "practice_proposal"
  end

  test "unhide restores a hidden default template" do
    @group.hidden_poll_templates = ["practice_proposal"]
    @group.save!

    sign_in @user
    post :unhide, params: { group_id: @group.id, key: "practice_proposal" }
    assert_response :success

    @group.reload
    refute_includes @group.hidden_poll_templates, "practice_proposal"
  end

  test "hide denies non-admin" do
    sign_in @another_user
    post :hide, params: { group_id: @group.id, key: "practice_proposal" }
    assert_response :not_found
  end

  test "unhide denies non-admin" do
    @group.hidden_poll_templates = ["practice_proposal"]
    @group.save!

    sign_in @another_user
    post :unhide, params: { group_id: @group.id, key: "practice_proposal" }
    assert_response :not_found
  end

  # === POSITIONS ===

  test "positions updates default template ordering by key" do
    sign_in @user
    post :positions, params: { group_id: @group.id, ids: ["poll", "check"] }
    assert_response :success

    @group.reload
    assert_equal 0, @group.poll_template_positions["poll"]
    assert_equal 1, @group.poll_template_positions["check"]
  end

  test "positions denies non-admin" do
    sign_in @another_user
    post :positions, params: { group_id: @group.id, ids: ["proposal"] }
    assert_response :not_found
  end

  # === SETTINGS ===

  test "settings updates categorize_poll_templates" do
    sign_in @user
    post :settings, params: { group_id: @group.id, categorize_poll_templates: false }
    assert_response :success
  end

  test "settings denies non-admin" do
    sign_in @another_user
    post :settings, params: { group_id: @group.id, categorize_poll_templates: false }
    assert_response :not_found
  end

  # === MEMBERS_CAN_CREATE_TEMPLATES ===

  test "member can create poll template when setting enabled" do
    @group.update!(members_can_create_templates: true)

    sign_in @another_user
    assert_difference 'PollTemplate.count', 1 do
      post :create, params: {
        poll_template: {
          group_id: @group.id,
          process_name: "Member Poll Template",
          process_subtitle: "subtitle",
          poll_type: "proposal",
          default_duration_in_days: 7
        }
      }
    end

    assert_response :success
    template = PollTemplate.last
    assert_equal @another_user.id, template.author_id
    assert_not template.discarded?, "member-created template should not be auto-discarded"
  end

  test "admin-created poll template is not auto-discarded" do
    @group.update!(members_can_create_templates: true)

    sign_in @user
    post :create, params: {
      poll_template: {
        group_id: @group.id,
        process_name: "Admin Poll Template",
        process_subtitle: "subtitle",
        poll_type: "proposal",
        default_duration_in_days: 7
      }
    }

    assert_response :success
    template = PollTemplate.last
    refute template.discarded?, "admin-created template should not be auto-discarded"
  end

  test "member can edit own poll template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @another_user)

    sign_in @another_user
    put :update, params: {
      id: template.id,
      poll_template: { process_name: "Updated by Member" }
    }

    assert_response :success
    template.reload
    assert_equal "Updated by Member", template.process_name
  end

  test "member cannot edit another member's poll template" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @user)

    sign_in @another_user
    put :update, params: {
      id: template.id,
      poll_template: { process_name: "Unauthorized Edit" }
    }

    assert_response :forbidden
  end

  test "member can discard own poll template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @another_user)

    sign_in @another_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    assert template.discarded?
  end

  test "member can undiscard own poll template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @another_user)
    template.discard!

    sign_in @another_user
    post :undiscard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    refute template.discarded?
  end

  test "member can destroy own poll template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @another_user)

    sign_in @another_user
    assert_difference 'PollTemplate.count', -1 do
      delete :destroy, params: { id: template.id }
    end
    assert_response :success
  end

  test "member cannot discard another member's poll template" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @user)

    sign_in @another_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :forbidden
  end

  test "member cannot undiscard another member's poll template" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @user)
    template.discard!

    sign_in @another_user
    post :undiscard, params: { id: template.id, group_id: @group.id }
    assert_response :forbidden
  end

  test "member cannot destroy another member's poll template" do
    @group.update!(members_can_create_templates: true)
    template = create_poll_template(author: @user)

    sign_in @another_user
    assert_no_difference 'PollTemplate.count' do
      delete :destroy, params: { id: template.id }
    end
    assert_response :forbidden
  end
end
