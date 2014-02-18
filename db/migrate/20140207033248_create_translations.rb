class CreateTranslations < ActiveRecord::Migration
  def change
  	create_table :translations do |t|
  		t.integer :translatable_id
  		t.string :translatable_type
  		t.string :translatable_field
  		t.text :translation
  		t.string :language
  		t.timestamps
  	end
  end
end
