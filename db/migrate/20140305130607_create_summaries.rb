class CreateSummaries < ActiveRecord::Migration
  def change
    create_table :summaries do |t|
      t.string   :kind
      t.datetime :start_time
      t.column   :timeframe, :interval
      t.string   :action
      t.integer  :count
      t.timestamps
    end
  end
end
