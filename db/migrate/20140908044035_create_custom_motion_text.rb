class CreateCustomMotionText < ActiveRecord::Migration
  def change
    add_column :motions, :yes_text, :string
    add_column :motions, :abstain_text, :string
    add_column :motions, :no_text, :string
    add_column :motions, :block_text, :string
  end
end
