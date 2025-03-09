class CreateWebpushData < ActiveRecord::Migration[7.0]
  def change
    create_table :webpush_certs do |t|
      t.string :public_key, null: false
      t.string :private_key, null: false

      t.timestamps
    end

    create_table :webpush_subscriptions do |t|
      t.string :endpoint, null: false
      t.string :p256dh, null: false
      t.string :auth, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
