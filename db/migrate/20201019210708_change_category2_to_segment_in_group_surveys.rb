class ChangeCategory2ToSegmentInGroupSurveys < ActiveRecord::Migration[5.2]
  def change
    rename_column :group_surveys, :category2, :segment
  end
end
