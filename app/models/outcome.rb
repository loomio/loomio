class Outcome < ActiveRecord::Base
  include MakesAnnouncements
  include HasMentions
  belongs_to :poll, required: true
  belongs_to :author, class_name: 'User', required: true
  has_one :discussion, through: :poll
  has_one :group, through: :discussion
  has_many :communities, through: :poll, class_name: "Communities::Base"

  has_many :events, -> { includes(:eventable) }, as: :eventable, dependent: :destroy

  delegate :title, to: :poll

  is_mentionable on: :statement

  validates :statement, {presence: true,
                         length: {maximum: Rails.application.secrets.max_message_length }}
end
