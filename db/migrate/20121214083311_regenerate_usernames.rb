class RegenerateUsernames < ActiveRecord::Migration
  def change
  	User.all.each do |user|
  		user.generate_username
  	end
  end
end
