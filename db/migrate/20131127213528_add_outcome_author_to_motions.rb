class AddOutcomeAuthorToMotions < ActiveRecord::Migration
  def up
    add_column :motions, :outcome_author_id, :integer
  end

  def down
    remove_column :motions, :outcome_author_id
  end
end
