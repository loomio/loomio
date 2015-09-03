class AddDefaultCoverData < ActiveRecord::Migration

  def up
    File.readlines(File.join(__dir__, "../default_group_covers.txt")).map do |url|
      DefaultGroupCover.store(url.chomp)
    end
  end

end
