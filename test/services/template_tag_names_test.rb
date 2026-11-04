require 'test_helper'

class TemplateTagNamesTest < ActiveSupport::TestCase
  setup do
    @topic = topics(:discussion_topic)
    @group = @topic.group
    @member = users(:member_normal)
    @admin = users(:admin)
    @group.update!(members_can_create_tags: false, members_can_create_templates: true)
  end

  test 'restricted members can apply organization and local template names regardless of selected template' do
    Tag.create!(group: @group, name: 'Organization')
    discussion_template(tags: ['Local discussion'])
    poll_template(tags: ['Local poll'])
    discussion_template(group: groups(:subgroup), tags: ['Subgroup only'])
    discussion_template(group: groups(:alien_group), public: true, tags: ['Foreign only'])

    assert_no_difference 'Tag.count' do
      assert_equal ['local discussion', 'Local poll', 'Organization'], permitted(
        [' Organization ', 'local   discussion', 'Local poll', 'Foreign only', 'Subgroup only', 'Invented'])
    end
  end

  test 'local defaults create actual tags only when a discussion or poll uses them' do
    discussion_template(tags: ['Discussion default'])
    poll_template(tags: ['Poll default'])
    assert_not Tag.exists?(name: ['Discussion default', 'Poll default'])

    discussion = DiscussionService.create(params: {title: 'Local defaults', group_id: @group.id,
      tags: ['Discussion default', 'Rejected discussion']}, actor: @member)
    poll = PollService.create(params: poll_params.merge(tags: ['Poll default', 'Rejected poll']), actor: @member)

    assert_equal ['Discussion default'], discussion.created_topic_item.tags
    assert_equal ['Poll default'], poll.created_topic_item.tags
    assert_equal ['Discussion default'], discussion.topic.reload.tags
    assert_equal ['Poll default'], poll.topic.reload.tags
    %w[Discussion Poll].each do |type|
      assert_includes Tag::COLORS, @group.tags.find_by!(name: "#{type} default").color
    end
    assert_not Tag.exists?(name: ['Rejected discussion', 'Rejected poll'])
  end

  test 'a foreign template cannot grant creation rights in the destination group' do
    discussion = discussion_template(group: groups(:alien_group), public: true, tags: ['Foreign discussion'])
    poll = poll_template(group: groups(:alien_group), public: true, tags: ['Foreign poll'])
    Tag.create!(group: @group, name: 'Organization')
    discussion_template(tags: ['Local'])

    created_discussion = DiscussionService.create(params: {title: 'Imported discussion', group_id: @group.id,
      discussion_template_id: discussion.id, tags: ['Foreign discussion', 'Organization', 'Local']}, actor: @member)
    created_poll = PollService.create(params: poll_params.merge(poll_template_id: poll.id,
      tags: ['Foreign poll', 'Organization', 'Local']), actor: @member)

    [created_discussion, created_poll].each do |created|
      assert_equal ['Local', 'Organization'], created.created_topic_item.tags
      assert_equal ['Local', 'Organization'], created.topic.reload.tags
    end
    assert_not Tag.exists?(name: ['Foreign discussion', 'Foreign poll'])
    assert_equal ['Foreign discussion'], discussion.reload.tags
    assert_equal ['Foreign poll'], poll.reload.tags
  end

  test 'applying tags to an existing contribution uses the same local template allowance' do
    discussion_template(tags: ['Local discussion'])
    poll_template(tags: ['Local poll'])
    item = @topic.topicable.created_topic_item
    TopicItemService.update_tags(topic_item: item, tags: ['Local poll', 'Rejected'], actor: @member)
    assert_equal ['Local poll'], item.reload.tags
    assert_equal ['Local poll'], @topic.reload.tags
    assert_not Tag.exists?(name: 'Rejected')
  end

  test 'the destination organization vocabulary includes tags from its other groups' do
    Tag.create!(group: @group, name: 'Parent vocabulary', used_group_ids: [@group.id])
    subgroup = groups(:subgroup)
    subgroup.update!(members_can_create_tags: false)
    assert_equal ['Parent vocabulary'], TagService.permitted_tag_names(subgroup, ['Parent vocabulary', 'Other'], users(:member_normal))
  end

  test 'template authors can freely edit defaults without creating or changing organization tags' do
    Tag.create!(group: @group, name: 'Existing', color: '#abcdef')
    assert_no_difference 'Tag.count' do
      discussion = DiscussionTemplateService.create(discussion_template: DiscussionTemplate.new(
        group: @group, process_name: 'Discussion', process_subtitle: 'Default', tags: ['New discussion']), actor: @member)
      poll = PollTemplateService.create(poll_template: PollTemplate.new(
        group: @group, process_name: 'Poll', process_subtitle: 'Default', poll_type: 'proposal', tags: ['New poll']), actor: @member)
      DiscussionTemplateService.update(discussion_template: discussion, params: {tags: ['Edited discussion']}, actor: @member)
      PollTemplateService.update(poll_template: poll, params: {tags: ['Edited poll']}, actor: @member)
      assert_equal ['Edited discussion'], discussion.reload.tags
      assert_equal ['Edited poll'], poll.reload.tags
    end
    assert_equal '#abcdef', @group.tags.find_by!(name: 'Existing').color
  end

  test 'template edit permissions still reject unrelated members and revoked authors' do
    discussion = discussion_template(author: @member, tags: ['Original discussion'])
    poll = poll_template(author: @member, tags: ['Original poll'])
    [users(:member_quiet), users(:alien_quiet), LoggedOutUser.new].each do |actor|
      assert_raises(CanCan::AccessDenied) do
        DiscussionTemplateService.update(discussion_template: discussion, params: {tags: ['Injected']}, actor: actor)
      end
      assert_raises(CanCan::AccessDenied) do
        PollTemplateService.update(poll_template: poll, params: {tags: ['Injected']}, actor: actor)
      end
    end
    memberships(:member_normal_membership).update!(revoked_at: Time.current)
    assert_raises(CanCan::AccessDenied) do
      DiscussionTemplateService.update(discussion_template: discussion, params: {tags: ['Injected']}, actor: @member)
    end
    assert_raises(CanCan::AccessDenied) do
      PollTemplateService.update(poll_template: poll, params: {tags: ['Injected']}, actor: @member)
    end
    assert_equal ['Original discussion'], discussion.reload.tags
    assert_equal ['Original poll'], poll.reload.tags
  end

  test 'guests and departed members cannot use private template names as a permission oracle' do
    discussion_template(tags: ['Private discussion'])
    discussion_template(tags: ['Public discussion'], public: true)
    poll_template(tags: ['Private poll'])
    poll_template(tags: ['Public poll'], public: true)
    names = ['Private discussion', 'Private poll', 'Public discussion', 'Public poll']
    %i[guest_normal alien_quiet non_guest_loud former_guest_loud former_member_loud inactive_member_loud].each do |role|
      assert_equal ['Public discussion', 'Public poll'], permitted(names, users(role)), role.to_s
    end
    assert_equal ['Public discussion', 'Public poll'], permitted(names, LoggedOutUser.new)
  end

  test 'guest intake allows visible discussion defaults but excludes hidden and discarded defaults' do
    @group.update!(group_privacy: 'closed', non_members_can_start_discussions: true)
    discussion_template(tags: ['Visible intake'])
    discussion_template(tags: ['Hidden intake'], hidden_at: Time.current)
    discussion_template(tags: ['Discarded intake'], discarded_at: Time.current)
    actor = users(:alien_quiet)
    assert actor.email_verified?
    assert_equal ['Visible intake'], permitted(['Visible intake', 'Hidden intake', 'Discarded intake'], actor)
    actor.update!(email_verified: false)
    assert_empty permitted(['Visible intake'], actor)
  end

  test 'discarded templates do not grant permission while member-accessible hidden templates do' do
    discussion_template(tags: ['Hidden discussion'], hidden_at: Time.current)
    poll_template(tags: ['Hidden poll'], hidden_at: Time.current)
    discussion_template(tags: ['Discarded discussion'], discarded_at: Time.current)
    poll_template(tags: ['Discarded poll'], discarded_at: Time.current)
    assert_equal ['Hidden discussion', 'Hidden poll'], permitted(
      ['Hidden discussion', 'Hidden poll', 'Discarded discussion', 'Discarded poll'])
  end

  test 'available built-in poll defaults are allowed without populating the organization on browse' do
    template = PollTemplateService.default_templates.find { |candidate| candidate.tags.any? }
    assert template
    assert_no_difference 'Tag.count' do
      assert_equal TagService.clean_tag_names(template.tags), permitted(template.tags)
    end
    @group.update!(hidden_poll_templates: [template.key])
    other_names = (PollTemplateService.default_templates + PollTemplateService.public_example_templates)
      .reject { |candidate| candidate.key == template.key }.flat_map(&:tags)
    hidden_only = template.tags - other_names
    assert hidden_only.any?
    assert_empty permitted(hidden_only)
  end

  test 'tag creation permission and coordinators retain normal behavior and direct topics need no organization' do
    assert_equal ['New'], permitted(['New'], @admin)
    @group.update!(members_can_create_tags: true)
    assert_equal ['New'], permitted(['New'])
    assert_equal ['Direct name'], TagService.permitted_tag_names(topics(:direct_topic).group, [' Direct name '], users(:guest_normal))
  end

  test 'renaming and deleting organization tags leaves template names independent and reusable' do
    discussion = discussion_template(tags: ['Independent'])
    poll = poll_template(tags: ['Independent'])
    tag = Tag.create!(group: @group, name: 'Independent')
    TagService.update(tag: tag, params: {name: 'Renamed', color: '#abcdef'}, actor: @admin)
    TagService.destroy(tag: tag.reload, actor: @admin)
    assert_equal ['Independent'], discussion.reload.tags
    assert_equal ['Independent'], poll.reload.tags
    assert_equal ['Independent'], permitted(['Independent'])
    assert_not Tag.exists?(name: ['Independent', 'Renamed'])
  end

  private

  def permitted(names, actor = @member)
    TagService.permitted_tag_names(@group, names, actor)
  end

  def discussion_template(**attrs)
    DiscussionTemplate.create!({group: @group, author: @admin, process_name: 'Discussion', process_subtitle: 'Default'}.merge(attrs))
  end

  def poll_template(**attrs)
    PollTemplate.create!({group: @group, author: @admin, process_name: 'Poll', process_subtitle: 'Default', poll_type: 'proposal'}.merge(attrs))
  end

  def poll_params
    {group_id: @group.id, title: 'Local poll', poll_type: 'proposal', poll_option_names: ['Agree', 'Disagree'], closing_at: 2.days.from_now}
  end
end
