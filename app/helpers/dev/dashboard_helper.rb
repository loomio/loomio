module Dev::DashboardHelper

  private

  def pinned_discussion
    create_discussion!(:pinned_discussion) { |discussion| pin!(discussion) }
  end

  def poll_discussion
    create_discussion!(:poll_discussion, group: create_poll_group) { |discussion| add_poll!(discussion) }
  end

  def recent_discussion(group: create_group)
    create_discussion!(:recent_discussion, group: group)
  end

  def old_discussion
    create_discussion!(:old_discussion) { |discussion| discussion.update last_activity_at: 2.years.ago }
  end

  def create_discussion!(name, group: create_group, author: patrick)
    var_name = :"@#{name}"
    if existing = instance_variable_get(var_name)
      existing
    else
      instance_variable_set(var_name, Discussion.create!(title: name.to_s.humanize, group: group, author: author, private: false).tap do |discussion|
        DiscussionService.create(discussion: discussion, actor: discussion.author)
        yield discussion if block_given?
      end)
    end
  end

  def pin!(discussion)
    DiscussionService.pin(discussion: discussion, actor: discussion.author)
  end

  def add_poll!(discussion, name: 'Test poll', actor: jennifer)
    PollService.create(poll: Poll.new(poll_type: :poll, poll_option_names: ["Apple", "Banana"], title: name, closing_at: 3.days.from_now, discussion: discussion), actor: actor)
  end

end
