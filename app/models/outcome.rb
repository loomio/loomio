class Outcome < ActiveRecord::Base
  include MakesAnnouncements
  include HasMentions
  belongs_to :poll, required: true
  belongs_to :poll_option, required: false
  belongs_to :author, class_name: 'User', required: true
  has_one :discussion, through: :poll
  has_one :group, through: :discussion
  has_many :communities, through: :poll, class_name: "Communities::Base"

  has_many :events, -> { includes(:eventable) }, as: :eventable, dependent: :destroy

  delegate :title, to: :poll

  is_mentionable on: :statement

  validates :statement, presence: true
  validate :has_valid_poll_option

  def has_valid_poll_option
    return if !self.poll_option_id || poll.poll_option_ids.includes?(self.poll_option_id)
    errors.add(:poll_option_id, I18n.t(:"outcome.error.invalid_poll_option"))
  end
end
