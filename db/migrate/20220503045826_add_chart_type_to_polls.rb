class AddChartTypeToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :chart_type, :string, default: 'bar', null: false
    add_column :polls, :chart_column, :string, default: 'max_score_percent', null: false
    add_column :polls, :icon_type, :string, default: 'bar', null: false
  end
end
