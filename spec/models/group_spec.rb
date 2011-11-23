require 'spec_helper'

describe Group do
  before :each do
    @group = Group.new
    @group.valid?
    @group
  end
  it "must have a name" do
    @group.should have(1).errors_on(:name)
  end
  it "has memberships" do
    @group.respond_to?(:memberships)
  end
end
