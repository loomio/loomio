class Api::V1::MentionsController < ApplicationController
  # return mentionables to the client

  def index
    mentionables = []
    load_and_authorize(:topic, optional: true)
    load_and_authorize(:group, optional: true)
    group_id = @topic&.group_id || @group&.id

    if @topic
      @topic.members.mention_search(params_query).limit(50).each do |user|
        mentionables << user_mention(user)
      end
    end

    if group_id
      Group
        .published
        .where(id: group_id)
        .where.not(handle: nil)
        .mention_search(params_query)
        .order("parent_id nulls first, name").limit(10)
        .each do |group|
        mentionables << group_mention(group) if current_user.can?(:notify, group)
      end
    end

    render json: mentionables, root: false
  end

  private

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
