class GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true

  def self.attributes_for_formal(*attrs)
    attrs.each do |attr|
      define_method attr, -> { object.send attr }
      define_method :"include_#{attr}?", -> { object.type == "FormalGroup" }
    end
    attributes *attrs
  end

  attributes :id,
             :cohort_id,
             :key,
             :handle,
             :type,
             :name,
             :full_name,
             :description,
             :logo_url_medium,
             :created_at,
             :creator_id,
             :members_can_add_members,
             :members_can_create_subgroups,
             :members_can_start_discussions,
             :members_can_edit_discussions,
             :members_can_edit_comments,
             :members_can_raise_motions,
             :members_can_vote,
             :polls_count,
             :closed_polls_count,
             :discussions_count,
             :public_discussions_count,
             :announcement_recipients_count,
             :group_privacy,
             :memberships_count,
             :invitations_count,
             :pending_invitations_count,
             :membership_granted_upon,
             :discussion_privacy_options,
             :has_discussions,
             :has_multiple_admins,
             :archived_at

  attributes_for_formal :cover_urls,
                        :has_custom_cover,
                        :experiences,
                        :enable_experiments,
                        :features,
                        :open_discussions_count,
                        :closed_discussions_count,
                        :recent_activity_count,
                        :is_subgroup_of_hidden_parent,
                        :is_visible_to_parent_members,
                        :parent_members_can_see_discussions

  has_one :current_user_membership, serializer: MembershipSerializer, root: :memberships
  has_one :parent, serializer: GroupSerializer, root: :groups

  def cover_photo
    @cover_photo ||= object.cover_photo
  end

  def logo_url_medium
    object.logo.url(:medium)
  end

  def include_logo_url_medium?
    type == "FormalGroup" && object.logo.present?
  end

  def cover_urls
    {
      small:      cover_photo.url(:desktop),
      medium:     cover_photo.url(:desktop),
      large:      cover_photo.url(:largedesktop),
      extralarge: cover_photo.url(:largedesktop)
    }
  end

  def has_custom_cover
    cover_photo.present?
  end

  def is_subgroup_of_hidden_parent
    object.is_subgroup_of_hidden_parent?
  end

  private

  def current_user_membership
    @current_user_membership ||= object.membership_for(scope[:current_user])
  end

  def include_current_user_membership?
    scope && scope[:current_user]
  end

  def has_discussions
    object.discussions_count > 0
  end

  def has_multiple_admins
    object.admin_memberships_count > 1
  end

end
