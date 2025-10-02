class Trial
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user_name,  :string
  attribute :user_email, :string
  attribute :user_legal_accepted, :boolean
  attribute :user_email_newsletter, :boolean
  attribute :current_user

  attribute :group_name, :string
  attribute :group_description, :string
  attribute :group_category, :string
  attribute :group_how_did_you_hear_about_loomio, :string

  validates :user_name, presence: true, length: { minimum: 2, maximum: 100 }, unless: :current_user_present?
  validates :user_email, presence: true, email: true, unless: :current_user_present?
  validates :user_legal_accepted, acceptance: true, unless: :current_user_present?

  validates :group_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :group_category, presence: true

  validate :user_email_is_not_taken

  def user_email_is_not_taken
    return if current_user_present?
    if User.where(email: user_email).exists?
      errors.add(:user_email, "Email address already exists. Please sign in to continue.")
    end
  end

  def current_user_present?
    current_user.present?
  end

  def current_or_create_user
    @current_or_create_user ||= current_user.presence || User.create(
      email: user_email.strip,
      name: user_name.strip,
      legal_accepted: user_legal_accepted,
      email_newsletter: user_email_newsletter
    )
  end

  def create_group
    group = Group.new(
      name: group_name,
      description: group_description,
      description_format: 'html',
      group_privacy: 'secret',
      category: group_category,
      info: { how_did_you_hear_about_loomio: group_how_did_you_hear_about_loomio },
      handle: GroupService.suggest_handle(name: group_name, parent_handle: nil)
    )
    GroupService.create(group: group, actor: current_or_create_user, skip_authorize: true)
    group
  end


end
