require 'spec_helper'

describe Membership do
  before :each do
    @membership = Membership.new
    @membership.valid?
  end
  it "must have a group" do
    @membership.should have(1).errors_on(:group)
  end
  it "must have a user" do
    @membership.should have(1).errors_on(:user)
  end
end
