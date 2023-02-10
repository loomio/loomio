module DiscussionExportRelations
  extend ActiveSupport::Concern

  included do
	  has_many :exportable_polls, -> { where("anonymous = false OR closed_at is not null") }, class_name: 'Poll', foreign_key: :group_id
	  has_many :exportable_poll_options,          through: :exportable_polls, source: :poll_options
	  has_many :exportable_outcomes,              through: :exportable_polls, source: :outcomes
	  has_many :exportable_stances,               through: :exportable_polls, source: :stances
	  has_many :exportable_stance_choices,        through: :exportable_stances, source: :stance_choices
	  has_many :comment_files,          through: :comments,            source: :files_attachments
	  has_many :comment_image_files,    through: :comments,            source: :image_files_attachments
	  has_many :poll_files,             through: :exportable_polls,    source: :files_attachments
	  has_many :poll_image_files,       through: :exportable_polls,    source: :image_files_attachments
	  has_many :outcome_files,          through: :exportable_outcomes, source: :files_attachments
	  has_many :outcome_image_files,    through: :exportable_outcomes, source: :image_files_attachments

	  has_many :exportable_poll_reactions,    -> { joins(:user) }, through: :exportable_polls,    source: :reactions
	  has_many :exportable_stance_reactions,  -> { joins(:user) }, through: :exportable_stances,  source: :reactions
	  has_many :comment_reactions,            -> { joins(:user) }, through: :comments,            source: :reactions
	  has_many :exportable_outcome_reactions, -> { joins(:user) }, through: :exportable_outcomes, source: :reactions
  end

  def all_reactions
    Queries::UnionQuery.for(:reactions, [
      self.reactions,
      self.exportable_poll_reactions,
      self.exportable_stance_reactions,
      self.comment_reactions,
      self.exportable_outcome_reactions
    ])
  end
end