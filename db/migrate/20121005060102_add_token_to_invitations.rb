class AddTokenToInvitations < ActiveRecord::Migration
  class Invitation < ActiveRecord::Base
    def generate_token
      begin
        token = SecureRandom.urlsafe_base64
      end while Invitation.where(:token => token).exists?
      self.token = token
    end
  end

  def up
    add_column :invitations, :token, :string
    Invitation.reset_column_information
    Invitation.all.each do |invitation|
      invitation.generate_token
      invitation.save(:validate => false)
    end
    change_column :invitations, :token, :string, :null => false
  end

  def down
    remove_column :invitations, :token
  end
end
