class AddAsciiConversionsInUsernames < ActiveRecord::Migration
  class User < ActiveRecord::Base
    def generate_username
      ensure_name_entry if name.nil?
      if name.include? '@'
        email_str = email.split("@").first
        new_username = email_str.parameterize.gsub(/[^a-z0-9]/, "")
      else
        new_username = name.parameterize.gsub(/[^a-z0-9]/, "")
      end
      username_tmp = new_username.dup.slice(0,18)
      num = 1
      while(User.where("username = ?", username_tmp).count > 0)
        break if username == username_tmp
        username_tmp = "#{new_username}#{num}"
        num+=1
      end
      self.username = username_tmp
      save
    end

    def ensure_name_entry
      unless name
        self.name = email
        save
      end
    end
  end

  def up
    User.find_each do |user|
      user.generate_username
    end
  end

  def down
  end
end
