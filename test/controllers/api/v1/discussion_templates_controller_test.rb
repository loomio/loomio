require 'test_helper'

class Api::V1::DiscussionTemplatesControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
  end

  # === INDEX ===

  test "index materializes default templates for group with no custom templates" do
    sign_in @user
    get :index, params: { group_id: @group.id }
    assert_response :success

    json = JSON.parse(response.body)
    templates = json['discussion_templates']
    assert templates.length > 0, "should return materialized templates"
    assert templates.all? { |t| t['id'].present? }, "all templates should have IDs"
  end

  test "index returns custom templates merged with materialized defaults" do
    DiscussionTemplateService.ensure_templates_materialized(@group)
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
    assert templates.length > 1, "should include materialized defaults"
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
    DiscussionTemplateService.ensure_templates_materialized(@group)

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

  test "destroy denies non-admin non-author" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Protected",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    delete :destroy, params: { id: template.id }
    assert_response :forbidden
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

  test "discard denies non-admin non-author" do
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Protected",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :forbidden
  end

  # === POSITIONS ===

  test "positions updates template ordering" do
    DiscussionTemplateService.ensure_templates_materialized(@group)
    t1 = DiscussionTemplate.create!(group: @group, author: @user, process_name: "First", process_subtitle: "s", position: 0)
    t2 = DiscussionTemplate.create!(group: @group, author: @user, process_name: "Second", process_subtitle: "s", position: 1)

    sign_in @user
    post :positions, params: { group_id: @group.id, ids: [t2.id, t1.id] }
    assert_response :success

    t1.reload
    t2.reload
    assert_equal 0, t2.position
    assert_equal 1, t1.position
  end

  test "positions denies non-admin" do
    sign_in @another_user
    post :positions, params: { group_id: @group.id, ids: [1] }
    assert_response :not_found
  end

  # === MATERIALIZATION ===

  test "ensure_templates_materialized creates DB records from YAML defaults" do
    assert_equal 0, @group.discussion_templates.count

    DiscussionTemplateService.ensure_templates_materialized(@group)

    templates = @group.discussion_templates.reload
    assert templates.count > 0, "should create template records"
    assert templates.all? { |t| t.id.present? }, "all should have IDs"
  end

  test "ensure_templates_materialized is idempotent" do
    DiscussionTemplateService.ensure_templates_materialized(@group)
    count = @group.discussion_templates.count

    DiscussionTemplateService.ensure_templates_materialized(@group)
    assert_equal count, @group.discussion_templates.count
  end

  test "ensure_templates_materialized marks non-visible defaults as discarded" do
    DiscussionTemplateService.ensure_templates_materialized(@group)

    visible_keys = DiscussionTemplateService::VISIBLE_BY_DEFAULT
    @group.discussion_templates.each do |t|
      if visible_keys.include?(t.key)
        refute t.discarded?, "#{t.key} should be visible by default"
      else
        assert t.discarded?, "#{t.key} should be hidden by default"
      end
    end
  end

  test "ensure_templates_materialized respects existing hidden_discussion_templates from group info" do
    @group[:info]['hidden_discussion_templates'] = ['blank']
    @group.save!

    DiscussionTemplateService.ensure_templates_materialized(@group)

    blank = @group.discussion_templates.find_by(key: 'blank')
    assert blank.discarded?, "blank should be discarded based on group info"

    practice = @group.discussion_templates.find_by(key: 'practice_thread')
    refute practice.discarded?, "practice_thread should not be discarded"
  end

  test "ensure_templates_materialized skips if group already has templates" do
    DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Existing",
      process_subtitle: "subtitle"
    )

    assert_no_difference '@group.discussion_templates.count' do
      DiscussionTemplateService.ensure_templates_materialized(@group)
    end
  end

  # === MEMBERS_CAN_CREATE_TEMPLATES ===

  test "member can create template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    DiscussionTemplateService.ensure_templates_materialized(@group)

    sign_in @another_user
    assert_difference 'DiscussionTemplate.count', 1 do
      post :create, params: {
        discussion_template: {
          group_id: @group.id,
          process_name: "Member Template",
          process_subtitle: "subtitle"
        }
      }
    end

    assert_response :success
    template = DiscussionTemplate.last
    assert_equal @another_user.id, template.author_id
    assert_not template.discarded?, "member-created template should not be auto-discarded"
  end

  test "admin-created template is not auto-discarded" do
    @group.update!(members_can_create_templates: true)
    DiscussionTemplateService.ensure_templates_materialized(@group)

    sign_in @user
    post :create, params: {
      discussion_template: {
        group_id: @group.id,
        process_name: "Admin Template",
        process_subtitle: "subtitle"
      }
    }

    assert_response :success
    template = DiscussionTemplate.last
    refute template.discarded?, "admin-created template should not be auto-discarded"
  end

  test "member can edit own template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @another_user,
      process_name: "Member's Template",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    put :update, params: {
      id: template.id,
      discussion_template: { process_name: "Updated by Member" }
    }

    assert_response :success
    template.reload
    assert_equal "Updated by Member", template.process_name
  end

  test "member cannot edit another member's template" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Admin's Template",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    put :update, params: {
      id: template.id,
      discussion_template: { process_name: "Unauthorized Edit" }
    }

    assert_response :forbidden
  end

  test "member can discard own template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @another_user,
      process_name: "Member Discardable",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    assert template.discarded?
  end

  test "member can destroy own template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @another_user,
      process_name: "Member Deletable",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    assert_difference 'DiscussionTemplate.count', -1 do
      delete :destroy, params: { id: template.id }
    end
    assert_response :success
  end

  test "member can undiscard own template when setting enabled" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @another_user,
      process_name: "Member Undiscardable",
      process_subtitle: "subtitle"
    )
    template.discard!

    sign_in @another_user
    post :undiscard, params: { id: template.id, group_id: @group.id }
    assert_response :success

    template.reload
    refute template.discarded?
  end

  test "member cannot discard another member's template" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Admin's Kept Template",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :forbidden
  end

  test "member cannot undiscard another member's template" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Admin's Hidden Template",
      process_subtitle: "subtitle"
    )
    template.discard!

    sign_in @another_user
    post :undiscard, params: { id: template.id, group_id: @group.id }
    assert_response :forbidden
  end

  test "member cannot destroy another member's template" do
    @group.update!(members_can_create_templates: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Admin's Template",
      process_subtitle: "subtitle"
    )

    sign_in @another_user
    assert_no_difference 'DiscussionTemplate.count' do
      delete :destroy, params: { id: template.id }
    end
    assert_response :forbidden
  end

  test "non-member cannot access discard" do
    other_user = User.create!(name: "Outsider #{SecureRandom.hex(4)}", email: "outsider_#{SecureRandom.hex(4)}@example.com", email_verified: true)
    template = DiscussionTemplate.create!(
      group: @group,
      author: @user,
      process_name: "Protected Template",
      process_subtitle: "subtitle"
    )

    sign_in other_user
    post :discard, params: { id: template.id, group_id: @group.id }
    assert_response :not_found
  end

  test "member cannot create template when setting disabled" do
    @group.update!(members_can_create_templates: false)

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

  # === DEFAULT_TO_DIRECT_DISCUSSION ===

  test "create with default_to_direct_discussion true" do
    DiscussionTemplateService.ensure_templates_materialized(@group)

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
    DiscussionTemplateService.ensure_templates_materialized(@group)
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
