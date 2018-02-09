class AddSequenceIdRangesString < ActiveRecord::Migration[4.2]
  def change
    add_column :discussions, :ranges_string, :string
  end
end
