class AddParamsToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :params, :text
  end
end
