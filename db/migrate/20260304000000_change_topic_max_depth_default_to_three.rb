class ChangeTopicMaxDepthDefaultToThree < ActiveRecord::Migration[7.0]
  def change
    change_column_default :topics, :max_depth, from: 2, to: 3
  end
end
