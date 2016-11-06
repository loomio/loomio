class SupportMultiplePollTypes < ActiveRecord::Migration
  def change
    add_column :motions, :kind, :string, default: :loomio, null: false
    add_column :votes, :stance, :jsonb, default: {}, null: false
  end
end
