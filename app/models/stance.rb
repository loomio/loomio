class Stance < ActiveRecord::Base
  include HasMentions

  ORDER_SCOPES = ['newest_first', 'oldest_first', 'priority_first', 'priority_last']

  is_mentionable  on: :reason

  belongs_to :poll, required: true
  has_many :stance_choices, dependent: :destroy
  has_many :poll_options, through: :stance_choices

  accepts_nested_attributes_for :stance_choices

  belongs_to :participant, polymorphic: true, required: true

  update_counter_cache :poll, :stances_count

  scope :latest, -> { where(latest: true) }

  scope :newest_first,   -> { order(created_at: :desc) }
  scope :oldest_first,   -> { order(created_at: :asc) }
  # scope :voters_a_to_z,  -> { joins(:participant).order('participants.name DESC') }
  # scope :voters_z_to_a,  -> { joins(:participant).order('participants.name ASC') }
  scope :priority_first, -> { joins(:poll_options).order('poll_options.priority ASC') }
  scope :priority_last,  -> { joins(:poll_options).order('poll_options.priority DESC') }

  validates :stance_choices, length: { minimum: 1 }

  delegate :group, to: :poll, allow_nil: true
  def author
    participant
  end

  def choice=(choice)
    if choice.kind_of?(Hash)
      self.stance_choices_attributes = poll.poll_options.where(name: choice.keys).map do |option|
        {poll_option_id: option.id,
         score: choice[option.name]}
      end
    else
      options = poll.poll_options.where(name: choice)
      self.stance_choices_attributes = options.map do |option|
        {poll_option_id: option.id}
      end
    end
  end
end
