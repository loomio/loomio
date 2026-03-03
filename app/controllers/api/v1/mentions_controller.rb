class Api::V1::MentionsController < ApplicationController
  # return mentionables to the client

  def index
    mentionables = []
    if topic_or_group&.group_id
      Group
        .published
        .where(id: topic_or_group.group_id)
        .where.not(handle: nil)
        .mention_search(params_query)
        .order("parent_id nulls first, name").limit(10)
        .each do |group|
        mentionables << group_mention(group) if current_user.can?(:notify, group)
      end
    end

    User.mention_search(topic_or_group || current_user, params_query).limit(50).each do |user|
      mentionables << user_mention(user)
    end

    render json: mentionables, root: false
  end

  private

  def topic_or_group
    @topic_or_group ||= begin
      model =
        load_and_authorize(:group, optional: true) ||
        load_and_authorize(:discussion, optional: true) ||
        load_and_authorize(:poll, optional: true) ||
        load_and_authorize(:comment, optional: true) ||
        load_and_authorize(:stance, optional: true) ||
        load_and_authorize(:outcome, optional: true)

      case model
      when Group, NilClass then model
      when Discussion, Poll then model.topic
      when Comment then model.topic
      when Stance then model.poll.topic
      when Outcome then model.poll.topic
      end
    end
  end

  def params_query
    String(params[:q]).strip.delete("\u0000")
  end

  def group_mention(group)
    {
      handle: group.handle,
      name: group.full_name
    }
  end

  def user_mention(user)
    {
      handle: user.username,
      name: user.name
    }
  end
end
