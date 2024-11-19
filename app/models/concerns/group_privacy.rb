module GroupPrivacy
  extend ActiveSupport::Concern

  MEMBERSHIP_GRANTED_UPON_OPTIONS = ['request', 'approval', 'invitation'].freeze

  included do
    after_initialize :set_privacy_defaults
    validate :validate_parent_members_can_see_discussions
    validate :validate_is_visible_to_parent_members
    validate :validate_visibility
    validate :validate_trial_group_cannot_be_public
    validates_inclusion_of :membership_granted_upon, in: MEMBERSHIP_GRANTED_UPON_OPTIONS
  end

  # this method's a bit chunky. New class?
  def group_privacy=(term)
    case term
    when 'open'
      self.listed_in_explore = true
      self.is_visible_to_public = true
      self.content_is_public = true
      unless %w[approval request invitation].include?(self.membership_granted_upon)
        self.membership_granted_upon = 'approval'
      end
    when 'closed'
      self.listed_in_explore = false
      self.is_visible_to_public = true
      self.content_is_public = false
      unless %w[approval invitation].include?(self.membership_granted_upon)
        self.membership_granted_upon = 'approval'
      end

      # closed subgroup of hidden parent means parent members can seeee it!
      if is_subgroup_of_hidden_parent?
        self.is_visible_to_parent_members = true
        self.is_visible_to_public = false
      end
    when 'secret'
      self.is_visible_to_public = false
      self.listed_in_explore = false
      self.content_is_public = false
      self.membership_granted_upon = 'invitation'
      self.is_visible_to_parent_members = false
    else
      raise "group_privacy term not recognised: #{term}"
    end
  end

  def group_privacy
    if is_visible_to_public?
      self.content_is_public ? 'open' : 'closed'
    elsif parent_id && is_visible_to_parent_members?
      'closed'
    else
      'secret'
    end
  end

  def validate_visibility
    self.content_is_public = false if !is_visible_to_public
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
        !is_visible_to_public and is_subgroup?
      else
        true
      end
    end
  end

  def set_privacy_defaults
    self.is_visible_to_public ||= false
    self.content_is_public ||= false
    self.membership_granted_upon ||= 'approval'
  end

end
