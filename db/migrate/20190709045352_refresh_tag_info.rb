class RefreshTagInfo < ActiveRecord::Migration[5.2]
  def change
    TagService.refresh_tag_info!
  end
end
