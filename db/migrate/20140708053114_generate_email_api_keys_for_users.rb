class GenerateEmailAPIKeysForUsers < ActiveRecord::Migration
  def up
    progress_bar = ProgressBar.create(format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                      progress_mark: "\e[32m/\e[0m",
                                      total: User.count)

    User.reset_column_information
    User.find_each do |user|
      user.update_attribute(:email_api_key, SecureRandom.hex(16))
      progress_bar.increment
    end
  end

  def down
  end
end
