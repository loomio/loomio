class DropChartColumnFromPolls < ActiveRecord::Migration[6.1]
  def change
    remove_column :polls, :chart_column
  end
end
