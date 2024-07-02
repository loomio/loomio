class CreateMentionableCollectionUsers < ActiveRecord::Migration[7.0]
  def up
    collections = User::MENTIONABLE_COLLECTIONS

    User.where(name: collections).each.with_index do |user|
      random_num = SecureRandom.random_number(9000) + 1000
      user.update!(name: "#{user.name}#{random_num}")
    end

    collections.each do |collection_name|
      User.create!(email: "#{collection_name}@loomio",
                        name: collection_name,
                        password: SecureRandom.hex(20),
                        email_verified: true,
                        collection: true,
                        avatar_kind: :gravatar)
    end
  end

  def down
    User.where(collection: true).destroy_all
  end
end
