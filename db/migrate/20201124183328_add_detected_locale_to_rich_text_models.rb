class AddDetectedLocaleToRichTextModels < ActiveRecord::Migration[5.2]
  def change
    add_column :groups,      :content_locale, :string, default: nil
    add_column :discussions, :content_locale, :string, default: nil
    add_column :comments,    :content_locale, :string, default: nil
    add_column :polls,       :content_locale, :string, default: nil
    add_column :stances,     :content_locale, :string, default: nil
    add_column :outcomes,    :content_locale, :string, default: nil
    add_column :users,       :content_locale, :string, default: nil
  end
end
