class FormalGroupSerializer < GroupSerializer
  attributes   :name,
               :full_name,
               :description,
               :logo_url_medium,
               :cover_urls,
               :has_custom_cover,
               :is_subgroup_of_hidden_parent,
               :is_visible_to_parent_members,
               :parent_members_can_see_discussions,
               :identity_id



  def cover_photo
    @cover_photo ||= object.cover_photo
  end

  def logo_url_medium
    object.logo.url(:medium)
  end

  def include_logo_url_medium?
    object.logo.present?
  end

  def cover_urls
    {
      small:  cover_photo.url(:desktop),
      medium: cover_photo.url(:desktop),
      large:  cover_photo.url(:largedesktop)
    }
  end

  def has_custom_cover
    cover_photo.present?
  end
  
  def is_subgroup_of_hidden_parent
    object.is_subgroup_of_hidden_parent?
  end

end
