class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.belongs_to :discussion
      t.string :kind, null: false
      t.string :uri, null: false
    end
  end
end
