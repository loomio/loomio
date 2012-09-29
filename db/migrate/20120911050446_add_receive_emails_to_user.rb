class AddReceiveEmailsToUser < ActiveRecord::Migration
  def up
  	unless column_exists? :users, :receive_emails
  		add_column :users, :receive_emails, :boolean, :default => true, :null => false
  	end
  end

  def down
  	unless !column_exists? :users, :receive_emails
  		remove_column :users, :receive_emails
  	end
  end
end
