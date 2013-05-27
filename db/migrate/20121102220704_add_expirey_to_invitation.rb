class AddExpireyToInvitation < ActiveRecord::Migration
  class Invitation < ActiveRecord::Base
  end
  class User < ActiveRecord::Base
  end
  def up
    expirey_date = Time.now + 3.months
    expired_date = Time.now - 3.days
    add_column :invitations, :expirey, :datetime, :default => expirey_date
    Invitation.reset_column_information

    Invitation.all.each do |invitation|
      if User.find_by_email(invitation.admin_email)
        invitation.expirey = expired_date
        invitation.save(:validate => false)
      end
    end
  end

  def down
    remove_column :invitations, :expirey
  end
end
