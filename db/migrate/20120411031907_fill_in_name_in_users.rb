class FillInNameInUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      if user.name == nil
        user.name = user.email
        user.save
      end
    end
  end

  def down
  end
end
