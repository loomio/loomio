class DigestQuery
  MENTION_KINDS = %w[user_mentioned comment_replied_to group_mentioned].freeze

  attr_reader :time_finish, :time_start, :user

  def initialize(user:, time_start:, time_finish: Time.current)
    @user = user
    @time_start = time_start
    @time_finish = time_finish
  end

  # The digest combines unseen directed activity with the existing unread-topic
  # roundup. Notification subjects are reauthorized against current access before
  # they are displayed or used to describe pending actions in the email subject.
  def notifications
    @notifications ||= NotificationQuery.currently_accessible_to(
      user: user,
      notifications: NotificationQuery.delivered_to(user: user, unseen: true)
                                      .where(created_at: time_start..time_finish)
                                      .includes(:actor, :subject, :notification_deliveries)
                                      .order(created_at: :desc)
    )
  end

  def topics
    @topics ||= TopicQuery.relevant_to(
      user: user,
      only_unread: true,
      or_subgroups: false
    ).where(last_activity_at: time_start..time_finish).to_a
  end

  def empty?
    notifications.empty? && topics.empty?
  end

  def subject(frequency:, site_name:)
    clauses = []
    if vote_needed_count.positive?
      clauses << I18n.t("email.catch_up.subject.votes_to_cast", count: vote_needed_count)
    end
    clauses << I18n.t("email.catch_up.subject.people_mentioned", count: people_mentioned_count) if people_mentioned_count.positive?
    clauses << I18n.t("email.catch_up.subject.polls_closing_soon", count: polls_closing_soon_count) if polls_closing_soon_count.positive?
    return clauses.join(I18n.t("email.catch_up.subject.separator")) if clauses.any?

    I18n.t("email.catch_up.#{frequency}_subject", site_name: site_name)
  end

  private

  def notification_poll(notification)
    subject = notification.subject_model
    subject.poll if subject.respond_to?(:poll)
  end

  def notification_polls
    @notification_polls ||= notifications.filter_map { |notification| notification_poll(notification) }.uniq(&:id)
  end

  def vote_needed_polls
    @vote_needed_polls ||= notification_polls.select { |poll| poll.vote_needed_from?(user) }
  end

  def vote_needed_count
    vote_needed_polls.count
  end


  def people_mentioned_count
    @people_mentioned_count ||= notifications
      .select { |notification| MENTION_KINDS.include?(notification.kind) }
      .filter_map(&:actor_id)
      .uniq
      .count
  end

  def polls_closing_soon_count
    @polls_closing_soon_count ||= notifications
      .select { |notification| notification.kind == "poll_closing_soon" }
      .filter_map { |notification| notification_poll(notification) }
      .uniq(&:id)
      .count(&:active?)
  end
end
