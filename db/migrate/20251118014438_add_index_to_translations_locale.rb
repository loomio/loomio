class AddIndexToTranslationsLocale < ActiveRecord::Migration[7.2]
  def change
    Translation.delete_all
    add_index :translations, :language
  end
end
