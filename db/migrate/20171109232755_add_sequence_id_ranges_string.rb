class AddSequenceIdRangesString < ActiveRecord::Migration
  def change
    add_column :discussions, :ranges_string, :string
  end
end
