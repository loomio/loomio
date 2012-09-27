class GroupRequest < ActiveRecord::Base
  attr_accessible :admin_email, :description, :expected_size, :name

  def approve!
    @group = Group.new(:name => name)
    @group.creator = User.create!(:email => admin_email,
                                  :name => admin_email,
                                  :password => SecureRandom.hex(16))
    @group.save!
    GroupMailer.new_group_invited_to_loomio
  end
end
