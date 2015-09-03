class AddDefaultCoverData < ActiveRecord::Migration

  def up
    File.readlines(File.join(__dir__, "../default_group_covers.txt")).map do |url|
      DefaultGroupCover.store(url.chomp)
    end

    Group.update_all("default_group_cover_id = (id % #{DefaultGroupCover.count}) + #{DefaultGroupCover.minimum(:id)}")
  end

end
