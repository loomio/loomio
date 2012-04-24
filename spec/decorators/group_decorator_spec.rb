require 'spec_helper'

describe GroupDecorator, :draper_with_helpers do
  before do
    @group = GroupDecorator.decorate(Group.make!)
    @subgroup = GroupDecorator.decorate(Group.make!(parent: @group))
  end

  context "full_link" do
    it "includes parent group in link" do
      @subgroup.full_link.should match(/#{@group.name}.+#{@subgroup.name}/)
    end
  end
end
