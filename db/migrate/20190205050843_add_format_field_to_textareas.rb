class AddFormatFieldToTextareas < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :description_format, :string, default: "md", null: false, limit: 10
    add_column :comments,    :body_format,        :string, default: "md", null: false, limit: 10
    add_column :polls,       :details_format,     :string, default: "md", null: false, limit: 10
    add_column :outcomes,    :statement_format,   :string, default: "md", null: false, limit: 10
    add_column :stances,     :reason_format,      :string, default: "md", null: false, limit: 10
    add_column :groups,      :description_format, :string, default: "md", null: false, limit: 10
    add_column :users,       :short_bio_format,   :string, default: "md", null: false, limit: 10
  end
end
