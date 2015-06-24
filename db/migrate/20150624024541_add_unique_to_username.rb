class AddUniqueToUsername < ActiveRecord::Migration
  def change
    User.where("username NOT SIMILAR TO '[a-z0-9]*'").each do |user|
      user.update_attribute(:username, user.username.downcase.gsub(/[^a-z0-9]*/, ''))
    end

    # remove duplicates

    users = User.where("username in
                (select username
                 from (select username, count(*) as count
                       from users
                       group by username
                       order by count desc) a
                 where count > 1)").order('id asc')
    users.each do |user|
      user.update_attribute(:username, UsernameGenerator.new(user).generate)
    end

    add_index :users, :username, unique: true
  end
end
