class Queries::GroupAnalytics
  include ActionView::Helpers::TextHelper

  def initialize(group:, since: 1.week.ago, till: 0.seconds.ago)
    @group, @since, @till = group, since, till
  end

  def stats
    {
      since:              @since,
      till:               @till,
      group_members:      @group.memberships.count,
      motions:            pluralize(eventables[:motion].count, 'proposal'),
      comments:           pluralize(eventables[:comment].count, 'comment'),
      votes:              pluralize(eventables[:vote].count, 'vote'),
      discussions:        pluralize(active_discussions.count, 'discussion thread'),
      active_members:     pluralize(active_users.count, 'member'),
      active_users:       active_users.map  { |u| activity_for(u) }
                                      .sort { |a,b| b[:motions_created] <=> a[:motions_created]}
                                      .take(10),
      has_activity:       eventables[:all].count > 0
    }
  end

  private

  def active_discussions
    @active_discussions ||= Discussion.find(events.pluck(:discussion_id)).uniq
  end

  def active_users
    @active_users ||= eventables[:all].map(&:author).uniq
  end

  def activity_for(user)
    {
      name:                user.name,
      motions_created:     authored_by(user, :motion),
      discussions_created: authored_by(user, :discussion),
      votes_created:       authored_by(user, :vote),
      comments_created:    authored_by(user, :comment)
    }
  end

  def authored_by(user, kind)
    eventables[kind].select { |e| e.author == user }.count
  end

  def eventables
    @eventables ||= {
      discussion: eventables_for(:discussion),
      motion:     eventables_for(:motion),
      comment:    eventables_for(:comment),
      vote:       eventables_for(:vote),
    }.tap { |h| h[:all] = h[:discussion] + h[:motion] + h[:comment] + h[:vote] }
  end

  def eventables_for(kind)
    kind.to_s.classify.constantize
        .joins(:user)
        .where(id: events.where(kind: :"new_#{kind}").pluck(:eventable_id))
        .where('users.email <> ?', ENV['HELPER_BOT_EMAIL'] || 'contact@loomio.org')
  end

  def events
    @events ||= Event.within(@since, @till)
                     .where("discussion_id IN (:discussion_ids) OR
                            (kind = 'new_discussion' AND eventable_id IN (:discussion_ids))", discussion_ids: all_discussion_ids)
  end

  def all_discussion_ids
    @all_discussion_ids ||= Discussion.where(group_id: @group.id_and_subgroup_ids).pluck(:id)
  end
end
