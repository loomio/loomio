class UpdateContentIsPublicForExistingGroups < ActiveRecord::Migration[7.0]
  def change
    Group.where(discussion_privacy_options: 'public_only').update_all(content_is_public: true)
  end
end
