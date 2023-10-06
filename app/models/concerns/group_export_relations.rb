module GroupExportRelations
  extend ActiveSupport::Concern

  included do
    #tags
    has_many :tags

    # polls
    has_many :exportable_polls, -> { where("anonymous = false OR closed_at is not null") }, class_name: 'Poll', foreign_key: :group_id

    has_many :discussion_taggings, through: :discussions, source: :taggings
    has_many :poll_taggings, through: :exportable_polls, source: :taggings
    has_many :exportable_poll_options,          through: :exportable_polls, source: :poll_options
    has_many :exportable_outcomes,              through: :exportable_polls, source: :outcomes
    has_many :exportable_stances,               through: :exportable_polls, source: :stances
    has_many :exportable_stance_choices,        through: :exportable_stances, source: :stance_choices

    # attachments
    has_many :comment_files,          through: :comments,            source: :files_attachments
    has_many :comment_image_files,    through: :comments,            source: :image_files_attachments
    has_many :discussion_files,       through: :discussions,         source: :files_attachments
    has_many :discussion_image_files, through: :discussions,         source: :image_files_attachments
    has_many :poll_files,             through: :exportable_polls,    source: :files_attachments
    has_many :poll_image_files,       through: :exportable_polls,    source: :image_files_attachments
    has_many :outcome_files,          through: :exportable_outcomes, source: :files_attachments
    has_many :outcome_image_files,    through: :exportable_outcomes, source: :image_files_attachments
    has_many :subgroup_files,         through: :subgroups,           source: :files_attachments
    has_many :subgroup_image_files,   through: :subgroups,           source: :image_files_attachments
    has_many :subgroup_cover_photos,  through: :subgroups,           source: :cover_photo_attachment
    has_many :subgroup_logos,         through: :subgroups,           source: :logo_attachment

    # documents
    has_many :discussion_documents,        through: :discussions,        source: :documents
    has_many :exportable_poll_documents,   through: :exportable_polls,   source: :documents
    has_many :comment_documents,           through: :comments,           source: :documents
    has_many :public_discussion_documents, through: :public_discussions, source: :documents
    has_many :public_comment_documents,    through: :public_comments,    source: :documents

    # reactions
    has_many :discussion_reactions,         -> { joins(:user) }, through: :discussions,         source: :reactions
    has_many :exportable_poll_reactions,    -> { joins(:user) }, through: :exportable_polls,    source: :reactions
    has_many :exportable_stance_reactions,  -> { joins(:user) }, through: :exportable_stances,  source: :reactions
    has_many :comment_reactions,            -> { joins(:user) }, through: :comments,            source: :reactions
    has_many :exportable_outcome_reactions, -> { joins(:user) }, through: :exportable_outcomes, source: :reactions

    # readers
    has_many :discussion_readers,  through: :discussions

    # users
    has_many :discussion_authors,         through: :discussions,                    source: :author
    has_many :comment_authors,            through: :comments,                       source: :user
    has_many :exportable_poll_authors,    through: :exportable_polls,               source: :author
    has_many :exportable_outcome_authors, through: :exportable_outcomes,            source: :author
    has_many :exportable_stance_authors,  through: :exportable_stances,             source: :participant
    has_many :reader_users,               through: :discussion_readers,             source: :user

    # events
    has_many :membership_events,          through: :memberships,          source: :events
    has_many :discussion_events,          through: :discussions,          source: :events
    has_many :comment_events,             through: :comments,             source: :events
    has_many :exportable_poll_events,     through: :exportable_polls,     source: :events
    has_many :exportable_outcome_events,  through: :exportable_outcomes,  source: :events
    has_many :exportable_stance_events,   through: :exportable_stances,   source: :events
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
      self.reader_users
    ])
  end

  # def related_attachments
  #   Queries::UnionQuery.for(:attachments, [
  #     self.comment_files,
  #     self.comment_image_files,
  #     self.discussion_files,
  #     self.discussion_image_files,
  #     self.poll_files,
  #     self.poll_image_files,
  #     self.outcome_files,
  #     self.outcome_image_files,
  #     self.subgroup_files,
  #     self.subgroup_image_files,
  #     self.subgroup_cover_photos,
  #     self.subgroup_logos,
  #   ])
  # end

  def all_taggings
    Queries::UnionQuery.for(:taggings, [
      self.discussion_taggings,
      self.poll_taggings
    ])
  end

  def all_groups
    Group.where(id: id_and_subgroup_ids)
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
