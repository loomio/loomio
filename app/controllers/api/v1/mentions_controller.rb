class Api::V1::MentionsController < ApplicationController
  # return mentionables to the client

  def index
    mentionables = []
    load_and_authorize(:topic, :members_autocomplete, optional: true)
    load_and_authorize(:group, :members_autocomplete, optional: true)
    group_id = @topic&.group_id || @group&.id

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

    mentionable_users_ordered.each do |user|
      mentionables << user_mention(user)
    end

    render json: mentionables, root: false
  end

  def count
    load_and_authorize(:topic, :members_autocomplete, optional: true)
    load_and_authorize(:group, :members_autocomplete, optional: true)
    group_id = @topic&.group_id || @group&.id

    user_ids = mentionable_users
      .verified
      .where(username: params_handles)
      .pluck(:id)

    group_ids = Group
      .published
      .where(id: group_id, handle: params_handles)
      .select { |group| current_user.can?(:notify, group) }
      .map(&:id)

    group_user_ids = Membership
      .active
      .accepted
      .where(group_id: group_ids)
      .where.not(user_id: current_user.id)
      .pluck(:user_id)

    count = User.active.where(id: user_ids.concat(group_user_ids).uniq).count
    render json: { count: }
  end

  private

  def params_query
    String(params[:q]).strip.delete("\u0000")
  end

  def params_handles
    String(params[:handles_cmr])
      .split(",")
      .map { |handle| handle.strip.delete("\u0000") }
      .reject(&:blank?)
      .uniq
      .first(100)
  end

  def mentionable_users
    return @topic.members if @topic
    return @group.members if @group

    User.none
  end

  def mentionable_users_ordered
    users = mentionable_users.mention_search(params_query)
    users = users.where.not(id: current_user.id) if params_query.blank?
    return users.limit(50).to_a unless @topic

    user_ids_recent = @topic.items
      .where.not(user_id: nil)
      .group(:user_id)
      .order(Arel.sql("MAX(sequence_id) DESC"))
      .limit(50)
      .pluck(:user_id)
    users_recent_by_id = users.where(id: user_ids_recent).index_by(&:id)
    users_ordered = user_ids_recent.filter_map { |id| users_recent_by_id[id] }
    users_remaining_count = 50 - users_ordered.length
    return users_ordered unless users_remaining_count.positive?

    users_ordered.concat(
      users.where.not(id: users_ordered.map(&:id)).limit(users_remaining_count)
    )
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
