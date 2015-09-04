class AddDefaultCoverData < ActiveRecord::Migration

  def up
    if !Rails.env.test?
      File.readlines(File.join(__dir__, "../default_group_covers.txt")).map do |url|
        DefaultGroupCover.store(url.chomp)
      end

      Group.where('parent_id IS NULL').update_all("default_group_cover_id = (id % #{DefaultGroupCover.count}) + #{DefaultGroupCover.minimum(:id)}")
    end
  end

end
