class AddDesiredFeatureToGroupSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :group_surveys, :desired_feature, :string
  end
end
