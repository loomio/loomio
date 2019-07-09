module GroupExportRelations
  extend ActiveSupport::Concern

  included do
    #tags
    has_many :discussion_tags, through: :discussions
    has_many :tags
    # polls
    has_many :discussion_polls, through: :discussions
    has_many :exportable_polls, -> { where anonymous: false }, class_name: 'Poll', foreign_key: :group_id

    has_many :exportable_poll_options,          through: :exportable_polls, source: :poll_options
    has_many :exportable_poll_unsubscriptions,  through: :exportable_polls, source: :poll_unsubscriptions
    has_many :exportable_poll_did_not_votes,    through: :exportable_polls, source: :poll_did_not_votes
    has_many :exportable_outcomes,              through: :exportable_polls, source: :outcomes
    has_many :exportable_stances,               through: :exportable_polls, source: :stances
    has_many :exportable_stance_choices,        through: :exportable_stances, source: :stance_choices


    # documents
    has_many :discussion_documents,        through: :discussions,        source: :documents
    has_many :exportable_poll_documents,   through: :exportable_polls,   source: :documents
    has_many :comment_documents,           through: :comments,           source: :documents
    has_many :public_discussion_documents, through: :public_discussions, source: :documents
    has_many :public_poll_documents,       through: :public_polls,       source: :documents
    has_many :public_comment_documents,    through: :public_comments,    source: :documents

    # reactions
    has_many :discussion_reactions,         -> { joins(:user) }, through: :discussions,         source: :reactions
    has_many :exportable_poll_reactions,    -> { joins(:user) }, through: :exportable_polls,    source: :reactions
    has_many :exportable_stance_reactions,  -> { joins(:user) }, through: :exportable_stances,  source: :reactions
    has_many :comment_reactions,            -> { joins(:user) }, through: :comments,            source: :reactions
    has_many :exportable_outcome_reactions, -> { joins(:user) }, through: :exportable_outcomes, source: :reactions

    # readers
    has_many :discussion_readers,  through: :discussions

    # guest groups
    has_many :discussion_guest_groups,      through: :discussions,        source: :guest_group
    has_many :exportable_poll_guest_groups, through: :exportable_polls,   source: :guest_group

    # users
    has_many :discussion_authors,         through: :discussions,                    source: :author
    # has_many :discussion_reader_users, through: :discussion_readers, source: :user
    has_many :comment_authors,            through: :comments,                       source: :user
    has_many :exportable_poll_authors,    through: :exportable_polls,               source: :author
    has_many :exportable_outcome_authors, through: :exportable_outcomes,            source: :author
    has_many :exportable_stance_authors,  through: :exportable_stances,             source: :participant
    has_many :reader_users,               through: :discussion_readers,             source: :user
    has_many :non_voters,                 through: :exportable_poll_did_not_votes,  source: :user

    # events
    has_many :membership_events,          through: :memberships,          source: :events
    has_many :discussion_events,          through: :discussions,          source: :events
    has_many :comment_events,             through: :comments,             source: :events
    has_many :exportable_poll_events,     through: :exportable_polls,     source: :events
    has_many :exportable_outcome_events,  through: :exportable_outcomes,  source: :events
    has_many :exportable_stance_events,   through: :exportable_stances,   source: :events
  end

  def all_groups
    Queries::UnionQuery.for(:groups, [
      Group.where(id: self.id),
      self.subgroups,
      self.discussion_guest_groups,
      self.exportable_poll_guest_groups
    ])
  end

  def all_users
    Queries::UnionQuery.for(:users, [
      self.members,
      self.discussion_authors,
      self.comment_authors,
      self.exportable_poll_authors,
      self.exportable_outcome_authors,
      self.exportable_stance_authors,
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
      self.exportable_poll_events,
      self.exportable_outcome_events,
      self.exportable_stance_events
    ])
  end

  def all_notifications
    Notification.where(event_id: all_events.pluck(:id))
  end

  def all_documents
    Queries::UnionQuery.for(:documents, [
      self.documents,
      self.discussion_documents,
      self.exportable_poll_documents,
      self.comment_documents
    ])
  end

  def all_reactions
    Queries::UnionQuery.for(:reactions, [
      self.discussion_reactions,
      self.exportable_poll_reactions,
      self.exportable_stance_reactions,
      self.comment_reactions,
      self.exportable_outcome_reactions
    ])
  end

  def reaction_users
    User.where(id: all_reactions.pluck(:user_id))
  end
end
