require 'rails_helper'

describe DeleteUserService do
  before do
    @user = FactoryBot.create :user
    @group = FactoryBot.create :formal_group
    @membership = @group.add_member! @user
    @discussion = FactoryBot.create :discussion, author: @user, group: @group
  end

  it "deactivates the user" do
    zombie = DeleteUserService.delete!(@user)
    expect(@membership.reload.archived_at).to be_present
  end

  it "migrates all their records to a zombie" do
    zombie = DeleteUserService.delete!(@user)
    expect(zombie.name).to eq "Deleted User"
    expect(zombie.archived_memberships.count).to eq 1
    expect(zombie.authored_discussions.count).to eq 1
  end

  it "deletes the user" do
    zombie = DeleteUserService.delete!(@user)
    expect { @user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
