class AddUniqueUserNamesToUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
    def generate_username
      ensure_name_entry if name.nil?
      if name.include? '@'
        #email used in place of name
        email_str = email.split("@").first 
        new_username = email_str.gsub(/\s+/, "").downcase
      else
        new_username = name.gsub(/\s+/, "").downcase
      end
      username_tmp = new_username.dup
      num = 1
      while(User.where("username = ?", username_tmp).count > 0)
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
    add_column :users, :username, :string
    User.all.each do |user|
      user.generate_username
    end
  end

  def down 
    remove_column :users, :username
  end
end
