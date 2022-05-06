class AddChartTypeToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :chart_type, :string
    add_column :polls, :chart_column, :string
    add_column :polls, :icon_type, :string
  end
end
