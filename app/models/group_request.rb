class GroupRequest < ActiveRecord::Base
  attr_accessible :admin_email, :description, :expected_size, :name

  belongs_to :group

  scope :approved, where(:status => :approved)
  scope :awaiting_approval, where(:status => :awaiting_approval)

  include AASM
  aasm :column => :status do  # defaults to aasm_state
    state :awaiting_approval, :initial => true
    state :approved
    state :ignored

    event :approve, :before => :approve_request do
      transitions :to => :approved, :from => [:awaiting_approval, :ignored]
    end

    event :ignore do
      transitions :to => :ignored, :from => [:awaiting_approval]
    end
  end

  private

  def approve_request
    @group = Group.new(:name => name)
    @group.creator = User.create!(:email => admin_email,
                                  :name => admin_email,
                                  :password => SecureRandom.hex(16))
    @group.save!
    self.group_id = @group.id
    GroupMailer.new_group_invited_to_loomio(admin_email, name).deliver
  end
end
