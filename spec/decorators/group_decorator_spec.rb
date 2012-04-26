require 'spec_helper'

describe GroupDecorator do
  before :each do
    c = ApplicationController.new
    c.request = ActionDispatch::TestRequest.new
    c.set_current_view_context

    @group = GroupDecorator.decorate(Group.make!)
    @subgroup = GroupDecorator.decorate(Group.make!(parent: @group))
  end

  context "full_link" do
    it "includes parent group in link" do
      @subgroup.full_link.should match(/#{@group.name}.+#{@subgroup.name}/)
    end
  end

  context "link" do
    it "has group name in link" do
      @group.link.should match(/#{@group.name}/)
    end
  end
end
