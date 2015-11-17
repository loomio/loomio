#### NB: These methods are deprecated and should not be relied upon going forward
module DeprecatedGroupFeatures
  extend ActiveSupport::Concern

  def visible_to=(term)
    case term.to_s
    when 'public'
      self.is_visible_to_public = true
      self.is_visible_to_parent_members = false
    when 'parent_members'
      self.is_visible_to_public = false
      self.is_visible_to_parent_members = true
    when 'members'
      self.is_visible_to_public = false
      self.is_visible_to_parent_members = false
      self.parent_members_can_see_discussions = false
      self.discussion_privacy_options = 'private_only'
      self.membership_granted_upon = 'invitation'
    end
  end

  def visible_to
    if is_visible_to_public?
      'public'
    elsif is_visible_to_parent_members?
      'parent_members'
    else
      'members'
    end
  end

end
