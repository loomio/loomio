class Api::V1::MentionsController < ApplicationController
  # return mentionables to the client

  def index
    mentionables = []
    if model&.group_id
      Group
        .published
        .where(id: model.group_id)
        .where.not(handle: nil)
        .mention_search(params_query)
        .order("parent_id nulls first, name").limit(10)
        .each do |group|
        mentionables << group_mention(group) if current_user.can?(:notify, group)
      end
    end

    User.mention_search(model || current_user, params_query).limit(50).each do |user|
      mentionables << user_mention(user)
    end

    render json: mentionables, root: false
  end

  private

  def model
    @model ||=
      load_and_authorize(:group, optional: true) ||
      load_and_authorize(:discussion, optional: true) ||
      load_and_authorize(:poll, optional: true) ||
      load_and_authorize(:comment, optional: true) ||
      load_and_authorize(:stance, optional: true) ||
      load_and_authorize(:outcome, optional: true)
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
