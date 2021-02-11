class ChangeGreyTagsToColors < ActiveRecord::Migration[5.2]
  def change
    execute "update tags set color = (array['#E91E63', '#9C27B0', '#3F51B5', '#2196F3', '#4CAF50', '#FF9800'])[floor(random() * 6 + 1)] where color = '#bbb'"
  end
end
