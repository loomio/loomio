class AddCategory2ToGroupSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :group_surveys, :category2, :string
  end
end
