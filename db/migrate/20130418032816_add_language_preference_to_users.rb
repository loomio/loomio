class AddLanguagePreferenceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :language_preference, :string
  end
end
