require 'test_helper'

class Api::V1::DiscussionTemplatesControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
  end

  # === INDEX ===

  test "index returns default templates for group with no custom templates" do
    sign_in @user
    get :index, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    templates = json['discussion_templates']
    assert templates.length > 0, "should return default templates"
    assert templates.any? { |t| t['key'].present? }, "default templates should have keys"
  end

  test "index returns custom templates merged with defaults" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Custom Process",
      process_subtitle: "Custom subtitle"
    )

    sign_in @user
    get :index, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    templates = json['discussion_templates']
    assert templates.any? { |t| t['id'] == template.id }, "should include custom template"
    assert templates.any? { |t| t['key'].present? }, "should include default templates"
  end

  test "index returns defaults when no group_id" do
    sign_in @user
    get :index
    assert_response :success

    json = JSON.parse(response.body)
    templates = json['discussion_templates']
    assert templates.length > 0, "should return default templates"
    assert templates.all? { |t| t['key'].present? }, "all should be default templates with keys"
  end

  test "index returns single template by id" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Find Me",
      process_subtitle: "subtitle"
    )

    sign_in @user
    get :index, params: { group_id: @group.id, id: template.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json['discussion_templates'].length
    assert_equal template.id, json['discussion_templates'][0]['id']
  end

  test "index cannot find template in another user group" do
    other_group = Group.create!(name: "Other Group #{SecureRandom.hex(4)}", creator: @another_user)

    template = DiscussionTemplate.create!(
      group: other_group,
      author: @another_user,
      process_name: "Secret",
      process_subtitle: "subtitle"
    )

    sign_in @user
    get :index, params: { id: template.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 0, json['discussion_templates'].length
  end

  test "index works without sign in and returns defaults" do
    get :index
    assert_response :success

    json = JSON.parse(response.body)
    templates = json['discussion_templates']
    assert templates.length > 0, "should return default templates for logged-out user"
  end

  test "index serializes key attribute" do
    sign_in @user
    get :index, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    templates = json['discussion_templates']
    default_template = templates.find { |t| t['key'] == 'blank' }
    assert default_template, "should have a blank default template with key serialized"
    assert_equal 'blank', default_template['key']
  end

  # === SHOW ===

  test "show returns a template in user group" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Showable",
      process_subtitle: "subtitle"
    )

    sign_in @user
    get :show, params: { id: template.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal template.id, json['discussion_templates'][0]['id']
  end

  test "show returns 404 for template not in user groups" do
    other_group = Group.create!(name: "Other #{SecureRandom.hex(4)}", creator: @another_user)
    template = DiscussionTemplate.create!(
      group: other_group,
      author: @another_user,
      process_name: "Hidden",
      process_subtitle: "subtitle"
    )

    sign_in @user
    get :show, params: { id: template.id }
    assert_response :not_found
  end

  # === CREATE ===

  test "create creates a discussion template" do
    sign_in @user

    assert_difference 'DiscussionTemplate.count', 1 do
      post :create, params: {
        discussion_template: {
          group_id: @group.id,
          process_name: "New Process",
          process_subtitle: "New subtitle",
          title: "Default title",
          description: "Template description",
          description_format: "html",
          max_depth: 2,
          newest_first: false
        }
      }
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "New Process", json['discussion_templates'][0]['process_name']
  end

  test "create denies non-admin" do
    sign_in @another_user
    post :create, params: {
      discussion_template: {
        group_id: @group.id,
        process_name: "Unauthorized",
        process_subtitle: "subtitle"
      }
    }
    assert_response :forbidden
  end

  # === UPDATE ===

  test "update modifies a discussion template" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Original",
      process_subtitle: "subtitle"
    )

    sign_in @user
    put :update, params: {
      id: template.id,
      discussion_template: { process_name: "Updated" }
    }

    assert_response :success
    template.reload
    assert_equal "Updated", template.process_name
  end

  # === DESTROY ===

  test "destroy deletes a discussion template" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Deletable",
      process_subtitle: "subtitle"
    )

    sign_in @user
    assert_difference 'DiscussionTemplate.count', -1 do
      delete :destroy, params: { id: template.id }
    end
    assert_response :success
  end

  test "destroy denies non-admin" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Protected",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    delete :destroy, params: { id: template.id }
    assert_response :not_found
  end

  # === DISCARD / UNDISCARD ===

  test "discard discards a discussion template" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Discardable",
      process_subtitle: "subtitle"
    )

    sign_in @user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    assert template.discarded?
  end

  test "undiscard restores a discarded discussion template" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Restorable",
      process_subtitle: "subtitle"
    )
    template.discard!

    sign_in @user
    post :undiscard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    refute template.discarded?
  end

  test "discard denies non-admin" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Protected",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :not_found
  end

  # === HIDE / UNHIDE (default templates) ===

  test "hide hides a default template for the group" do
    sign_in @user
    post :hide, params: { group_id: @group.id, key: "blank" }
    assert_response :success

    @group.reload
    assert_includes @group.hidden_discussion_templates, "blank"
  end

  test "unhide restores a hidden default template" do
    @group.hidden_discussion_templates = ["blank"]
    @group.save!

    sign_in @user
    post :unhide, params: { group_id: @group.id, key: "blank" }
    assert_response :success

    @group.reload
    refute_includes @group.hidden_discussion_templates, "blank"
  end

  test "hide denies non-admin" do
    sign_in @another_user
    post :hide, params: { group_id: @group.id, key: "blank" }
    assert_response :not_found
  end

  # === POSITIONS ===

  test "positions updates template ordering" do
    t1 = DiscussionTemplate.create!(group: @group, author: @user, process_name: "First", process_subtitle: "s", position: 0)
    t2 = DiscussionTemplate.create!(group: @group, author: @user, process_name: "Second", process_subtitle: "s", position: 1)

    sign_in @user
    post :positions, params: { group_id: @group.id, ids: [t2.id, t1.id] }
    assert_response :success

    @group.reload
    assert_equal 0, @group.discussion_template_positions[t2.id.to_s]
    assert_equal 1, @group.discussion_template_positions[t1.id.to_s]
  end

  test "positions can reorder default templates by key" do
    sign_in @user
    post :positions, params: { group_id: @group.id, ids: ["blank", "practice_thread"] }
    assert_response :success

    @group.reload
    assert_equal 0, @group.discussion_template_positions["blank"]
    assert_equal 1, @group.discussion_template_positions["practice_thread"]
  end

  test "positions denies non-admin" do
    sign_in @another_user
    post :positions, params: { group_id: @group.id, ids: ["blank"] }
    assert_response :not_found
  end

  # === DEFAULT_TO_DIRECT_DISCUSSION ===

  test "create with default_to_direct_discussion true" do
    sign_in @user
    post :create, params: {
      discussion_template: {
        group_id: @group.id,
        process_name: "Direct Process",
        process_subtitle: "subtitle",
        default_to_direct_discussion: true
      }
    }
    assert_response :success

    json = JSON.parse(response.body)
    template = json['discussion_templates'][0]
    assert_equal true, template['default_to_direct_discussion']
  end

  test "index serializes default_to_direct_discussion" do
    DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Direct Template",
      process_subtitle: "subtitle",
      default_to_direct_discussion: true
    )

    sign_in @user
    get :index, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    template = json['discussion_templates'].find { |t| t['process_name'] == 'Direct Template' }
    assert template, "should include the custom template"
    assert_equal true, template['default_to_direct_discussion']
  end

  test "update default_to_direct_discussion" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Toggle Direct",
      process_subtitle: "subtitle",
      default_to_direct_discussion: false
    )

    sign_in @user
    put :update, params: {
      id: template.id,
      discussion_template: { default_to_direct_discussion: true }
    }

    assert_response :success
    template.reload
    assert_equal true, template.default_to_direct_discussion
  end
end
