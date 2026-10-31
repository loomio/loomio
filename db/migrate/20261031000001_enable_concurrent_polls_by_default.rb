class EnableConcurrentPollsByDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :topics, :allow_concurrent_polls, from: false, to: true
    change_column_default :discussion_templates, :allow_concurrent_polls, from: false, to: true
  end
end
