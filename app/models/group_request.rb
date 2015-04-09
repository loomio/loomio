class GroupRequest < ActiveRecord::Base

  attr_accessor :payment_plan

  validates :name, presence: true, length: {maximum: 250}
  validates :admin_name, presence: true, length: {maximum: 250}
  validates :admin_email, presence: true, email: true
  validates_inclusion_of :is_commercial, in: [true, false], message: I18n.t(:'group_request.please_select_an_option')

  belongs_to :group

  scope :starred, -> { where(high_touch: true) }
  scope :not_starred, -> { where(high_touch: false) }
  scope :not_setup, -> { joins(:group).where("groups.setup_completed_at IS NULL") }
  scope :setup_completed, -> { joins(:group).where('groups.setup_completed_at IS NOT NULL') }
  scope :zero_members, -> { joins(:group).where(groups: {memberships_count: 0}) }

  before_destroy :prevent_destroy_if_group_present
  before_validation :generate_token, on: :create

  def admin_first_name
    admin_name.split(' ').first
  end

  def name_and_email
    "#{admin_name} <#{admin_email}>"
  end

  private

  def prevent_destroy_if_group_present
    if self.group.present?
      errors.add(:group, "dont' delete group requests ok!")
    end
    errors.blank?
  end

  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while self.class.where(:token => token).exists?
    self.token = token
  end
end
