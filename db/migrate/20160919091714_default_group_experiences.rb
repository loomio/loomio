class DefaultGroupExperiences < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:groups, :experiences, {})
    Group.where(experiences: '{}').update_all(experiences: {})
  end
end
