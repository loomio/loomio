module GroupPrivacy
  extend ActiveSupport::Concern

  DISCUSSION_PRIVACY_OPTIONS = ['public_only', 'private_only', 'public_or_private'].freeze
  MEMBERSHIP_GRANTED_UPON_OPTIONS = ['request', 'approval', 'invitation'].freeze

  included do
    after_initialize :set_privacy_defaults
    before_validation :set_discussions_private_only, if: :is_hidden_from_public?
    validate :validate_parent_members_can_see_discussions
    validate :validate_is_visible_to_parent_members
    validate :validate_discussion_privacy_options
    validate :validate_trial_group_cannot_be_public
    validate do
      # Enforce the parent boundary for API callers and direct visibility writes.
      errors.add(:group_privacy, :invalid) if is_visible_to_public? && is_subgroup_of_hidden_parent?
    end
    validates_inclusion_of :discussion_privacy_options, in: DISCUSSION_PRIVACY_OPTIONS
    validates_inclusion_of :membership_granted_upon, in: MEMBERSHIP_GRANTED_UPON_OPTIONS
  end

  # Privacy presets explicitly write the existing visibility flags. Validation
  # prevents public subgroup visibility beneath a hidden parent.
  def group_privacy=(term)
    self.listed_in_explore = false if is_subgroup?

    case term
    when 'open'
      self.is_visible_to_public = true
      self.is_visible_to_parent_members = false
      self.discussion_privacy_options = 'public_only'
      unless %w[approval request invitation].include?(self.membership_granted_upon)
        self.membership_granted_upon = 'approval'
      end
    when 'closed'
      self.is_visible_to_public = true
      self.is_visible_to_parent_members = false
      unless %w[private_only public_or_private].include?(self.discussion_privacy_options)
        self.discussion_privacy_options = 'private_only'
      end
    when 'parent_members'
      self.is_visible_to_public = false
      self.is_visible_to_parent_members = true
      self.discussion_privacy_options = 'private_only'
      self.listed_in_explore = false
    when 'secret'
      self.is_visible_to_public = false
      self.listed_in_explore = false
      self.discussion_privacy_options = 'private_only'
      self.membership_granted_upon = 'invitation'
      self.is_visible_to_parent_members = false
      self.parent_members_can_see_discussions = false
    else
      raise "group_privacy term not recognised: #{term}"
    end
  end

  def group_privacy
    if is_visible_to_public?
      self.public_discussions_only? ? 'open' : 'closed'
    elsif parent_id && is_visible_to_parent_members?
      'parent_members'
    else
      'secret'
    end
  end

  def is_hidden_from_public?
    !is_visible_to_public?
  end

  def private_discussions_only?
    discussion_privacy_options == 'private_only'
  end

  def public_discussions_only?
    discussion_privacy_options == 'public_only'
  end

  def public_or_private_discussions_allowed?
    discussion_privacy_options == 'public_or_private'
  end

  def membership_granted_upon_approval?
    membership_granted_upon == 'approval'
  end

  def membership_granted_upon_request?
    membership_granted_upon == 'request'
  end

  def membership_granted_upon_invitation?
    membership_granted_upon == 'invitation'
  end

  def discussion_private_default
    self.discussion_privacy_options != "public_only"
  end

  def set_discussions_private_only
    self.discussion_privacy_options = 'private_only'
  end

  def validate_discussion_privacy_options
    unless is_visible_to_parent_members?
      if group_privacy == 'open' and !public_discussions_only?
        self.errors.add(:discussion_privacy_options, "Discussions must be public if group is open")
      end
    end

    if is_hidden_from_public? and not private_discussions_only?
      self.errors.add(:discussion_privacy_options, "Discussions must be private if group is hidden")
    end
  end

  def validate_parent_members_can_see_discussions
    self.errors.add(:parent_members_can_see_discussions) unless parent_members_can_see_discussions_is_valid?
  end

  def validate_is_visible_to_parent_members
    self.errors.add(:is_visible_to_parent_members) unless visible_to_parent_members_is_valid?
  end

  def validate_trial_group_cannot_be_public
    if !self.parent_id &&
       self.subscription &&
       self.subscription.plan == 'trial' &&
       self.is_visible_to_public
      self.errors.add(:group_privacy, I18n.t('group.error.no_public_trials'))
    end
  end

  def parent_members_can_see_discussions_is_valid?
    if is_visible_to_public?
      true
    else
      if parent_members_can_see_discussions?
        is_visible_to_parent_members?
      else
        true
      end
    end
  end

  def visible_to_parent_members_is_valid?
    if is_visible_to_public?
      true
    else
      if is_visible_to_parent_members?
        is_hidden_from_public? and is_subgroup?
      else
        true
      end
    end
  end

  def set_privacy_defaults
    self.is_visible_to_public ||= false
    self.discussion_privacy_options ||= 'private_only'
    self.membership_granted_upon ||= 'approval'
  end

end
