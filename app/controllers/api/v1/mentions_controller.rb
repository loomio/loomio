class API::V1::MentionsController < ApplicationController
  # return mentionables to the client

  def index
    mentionables = []
    if model&.group_id
      Group.published
           # .where(id: model.group.id_and_subgroup_ids & current_user.group_ids)
           .where(id: model.group_id)
           .where.not(handle: nil)
           .mention_search(params_query)
           .each do |g|
        mentionables << group_mention(g)
      end
    end

    User.mention_search(model, params_query).limit(50).each do |user|
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
      name: group.name
    }
  end

  def user_mention(user)
    {
      handle: user.username,
      name: user.name
    }
  end
end
