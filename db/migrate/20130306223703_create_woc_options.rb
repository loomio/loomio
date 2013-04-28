class CreateWocOptions < ActiveRecord::Migration
  def change
    drop_table :woc_options if table_exists? :woc_options
    create_table :woc_options do |t|
      t.string :example_discussion_url

      t.timestamps
    end
  end
end
