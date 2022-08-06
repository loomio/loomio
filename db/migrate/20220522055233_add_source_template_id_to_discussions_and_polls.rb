class AddSourceTemplateIdToDiscussionsAndPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :source_template_id, :integer
    add_column :polls, :source_template_id, :integer
    add_index :discussions, :source_template_id, where: "source_template_id IS NOT NULL"
    add_index :polls, :source_template_id, where: "source_template_id IS NOT NULL"
  end
end
