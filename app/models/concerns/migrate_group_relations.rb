module MigrateGroupRelations
  extend ActiveSupport::Concern

  included do
    # comments
    has_many :comments, through: :discussions

    # polls
    has_many :discussion_polls, through: :discussions
    has_many :poll_options, through: :polls
    has_many :poll_unsubscriptions, through: :polls
    has_many :poll_did_not_votes, through: :polls
    has_many :outcomes, through: :polls
    has_many :stances, through: :polls
    has_many :stance_choices, through: :stances

    # documents
    has_many :discussion_documents,        through: :discussions,        source: :documents
    has_many :poll_documents,              through: :polls,              source: :documents
    has_many :comment_documents,           through: :comments,           source: :documents
    has_many :public_discussion_documents, through: :public_discussions, source: :documents
    has_many :public_poll_documents,       through: :public_polls,       source: :documents
    has_many :public_comment_documents,    through: :public_comments,    source: :documents

    # reactions
    has_many :discussion_reactions,        -> { joins(:user) }, through: :discussions, source: :reactions
    has_many :poll_reactions,              -> { joins(:user) }, through: :polls,       source: :reactions
    has_many :stance_reactions,            -> { joins(:user) }, through: :stances,     source: :reactions
    has_many :comment_reactions,           -> { joins(:user) }, through: :comments,    source: :reactions
    has_many :outcome_reactions,           -> { joins(:user) }, through: :outcomes,    source: :reactions

    # readers
    has_many :discussion_readers, through: :discussions

    # guest groups
    # has_many :discussion_guest_groups,     through: :discussions,        source: :guest_group
    has_many :poll_guest_groups,           through: :polls,              source: :guest_group

    # users
    has_many :discussion_authors, through: :discussions,        source: :author
    has_many :comment_authors,    through: :comments,           source: :user
    has_many :poll_authors,       through: :polls,              source: :author
    has_many :outcome_authors,    through: :outcomes,           source: :author
    has_many :stance_authors,     through: :stances,            source: :participant
    has_many :reader_users,       through: :discussion_readers, source: :user
    has_many :non_voters,         through: :poll_did_not_votes, source: :user

    # events
    has_many :membership_events, through: :memberships, source: :events
    has_many :discussion_events, through: :discussions, source: :events
    has_many :comment_events,    through: :comments,    source: :events
    has_many :poll_events,       through: :polls,       source: :events
    has_many :outcome_events,    through: :outcomes,    source: :events
    has_many :stance_events,     through: :stances,     source: :events
  end

  def all_groups
    Queries::UnionQuery.for(:groups, [
      self.subgroups,
      # self.discussion_guest_groups,
      self.poll_guest_groups
    ])
  end

  def all_users
    Queries::UnionQuery.for(:users, [
      self.members,
      self.discussion_authors,
      self.comment_authors,
      self.poll_authors,
      self.outcome_authors,
      self.stance_authors,
      self.reaction_users,
      self.reader_users,
      self.non_voters
    ])
  end

  def all_events
    Queries::UnionQuery.for(:events, [
      self.membership_events,
      self.discussion_events,
      self.comment_events,
      self.poll_events,
      self.outcome_events,
      self.stance_events
    ])
  end

  def all_notifications
    Notification.where(event_id: all_events.pluck(:id))
  end

  def all_documents
    Queries::UnionQuery.for(:documents, [
      self.documents,
      self.discussion_documents,
      self.poll_documents,
      self.comment_documents
    ])
  end

  def all_reactions
    Queries::UnionQuery.for(:reactions, [
      self.discussion_reactions,
      self.poll_reactions,
      self.stance_reactions,
      self.comment_reactions,
      self.outcome_reactions
    ])
  end

  def reaction_users
    User.where(id: all_reactions.pluck(:user_id))
  end
end
