require 'test_helper'

class ConcurrentPollDefaultsTest < ActiveSupport::TestCase
  test 'new group and direct threads permit multiple active polls by default' do
    [groups(:group).id, nil].each do |group_id|
      actor = users(:member_normal)
      discussion = DiscussionService.create(params: {title: 'Concurrent decisions', group_id: group_id}, actor: actor)
      assert discussion.topic.allow_concurrent_polls?

      2.times do
        poll = PollService.create(params: poll_params(discussion.topic), actor: actor)
        assert poll.persisted?, poll.errors.full_messages.join(', ')
      end
      assert_equal 2, discussion.topic.reload.active_polls_count

      outsider = users(:alien)
      assert_not outsider.can?(:create, PollService.build(params: poll_params(discussion.topic), actor: outsider))
    end
  end

  test 'an explicit single-poll setting still prevents concurrent polls for thread and group admins' do
    [groups(:group).id, nil].each do |group_id|
      actor = users(:member_normal)
      discussion = DiscussionService.create(params: {
        title: 'One decision at a time', group_id: group_id, allow_concurrent_polls: false
      }, actor: actor)
      first = PollService.create(params: poll_params(discussion.topic), actor: actor)
      assert first.persisted?
      assert_not discussion.topic.reload.allow_concurrent_polls?

      admins = group_id ? [actor, users(:admin)] : [actor]
      admins.each do |admin|
        assert admin.can?(:update, discussion.topic)
        assert_raises CanCan::AccessDenied do
          PollService.create(params: poll_params(discussion.topic), actor: admin)
        end
      end
      assert_equal 1, discussion.topic.reload.active_polls_count
    end
  end

  test 'new built-in discussion templates carry concurrent polls into the group template list' do
    defaults = AppConfig.discussion_templates.values
    assert defaults.any?
    assert defaults.all? { |settings| settings.fetch('allow_concurrent_polls') == true }

    assert DiscussionTemplateService.default_templates.all?(&:allow_concurrent_polls?)
    templates = DiscussionTemplateService.group_templates(group: groups(:group))
    assert templates.any?
    assert templates.all?(&:allow_concurrent_polls?)

    template = templates.find { |item| item.key == 'blank' }
    template.update!(allow_concurrent_polls: false)
    reloaded = DiscussionTemplateService.group_templates(group: groups(:group)).find { |item| item.id == template.id }
    assert_not reloaded.allow_concurrent_polls?
  end

  private

  def poll_params(topic)
    {topic_id: topic.id, title: 'A decision', poll_type: 'proposal', poll_option_names: %w[Agree Disagree], closing_at: 2.days.from_now}
  end
end
