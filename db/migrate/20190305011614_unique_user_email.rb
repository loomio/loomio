class UniqueUserEmail < ActiveRecord::Migration[5.2]
  def change
    User.where(email_verified: false).find_each do |unverified_user|
      if verfied_user = User.find_by(email_verified: true, email: user.email)
        service = MigrateUserService.new(source: unverified_user, destination: verified_user)
        service.delete_duplicates
        service.operations.each { |operation| ActiveRecord::Base.connection.execute(operation) }
        service.migrate_stances
        service.update_counters
        unverified_user.delete!
      end
    end

    User.where(email_verified: false).find_each do |user|
      User.where(email_verified: false, email: unverified_user.email).where("id != ?", user.id).each do |dupe_user|
        service = MigrateUserService.new(source: user, destination: dupe_user)
        service.delete_duplicates
        service.operations.each { |operation| ActiveRecord::Base.connection.execute(operation) }
        service.migrate_stances
        service.update_counters
        unverified_user.delete!
      end
    end

    # tests:
    #   verified user count should stay the same
    #   total unique emails should stay the same
    #   unvierified users will drop

    remove_index :users, name: :index_users_on_email
    remove_index :users, name: :email_verified_and_unique
    add_index    :users, :email, unique: true
  end
end
