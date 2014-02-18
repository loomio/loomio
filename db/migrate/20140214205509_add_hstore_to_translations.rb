class AddHstoreToTranslations < ActiveRecord::Migration
  def change
    add_column :translations, :fields, :hstore
    remove_column :translations, :translation
    remove_column :translations, :translatable_field
  end
end
