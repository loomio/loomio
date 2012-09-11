class AddOutcomeToMotion < ActiveRecord::Migration
  def change
    add_column :motions, :outcome, :string
  end
end
