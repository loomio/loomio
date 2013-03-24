class CreateWocOptions < ActiveRecord::Migration
  def change
    create_table :woc_options do |t|
      t.string :example_discussion_url

      t.timestamps
    end
  end
end
