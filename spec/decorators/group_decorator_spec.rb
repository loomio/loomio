require 'spec_helper'

describe GroupDecorator do
  before :each do
    c = ApplicationController.new
    c.request = ActionDispatch::TestRequest.new
    c.set_current_view_context

    @group = GroupDecorator.decorate(create(:group, name: "Chanelle Hara"))
    @subgroup = GroupDecorator.decorate(create(:group, parent: @group))
  end

  describe "link" do
    it "has group name in link" do
      @group.link.should match(/#{@group.name}/)
    end
  end

  describe "fancy_name" do
    it "result contains group name" do
      @group.fancy_name.should =~ /#{@group.name}/
    end
    context "of a subgroup" do
      it "result contains parent group name" do
        @subgroup.fancy_name.should match("#{@group.name}")
      end
      it "result contains group name" do
        @subgroup.fancy_name.should match("#{@subgroup.name}")
      end
      context "where show_parent_name = false" do
        it "result does not contain parent name" do
          @subgroup.fancy_name(false).should_not match("#{@group.name}")
        end
      end
    end
  end

  describe "fancy_link" do
    it "result contains a link to group" do
      @group.fancy_link.should =~ /\/g\/#{@group.key}/
    end
    context "of a subgroup" do
      it "result contains a link to subgroup" do
        @subgroup.fancy_link.should =~ /\/g\/#{@subgroup.key}/
      end
      it "result contains a link to parent group" do
        @subgroup.fancy_link.should =~ /\/g\/#{@group.key}/
      end
    end
    context "where show_parent_name = false" do
      it "result does not contain parent link" do
        @subgroup.fancy_link(false).should_not =~ /\/g\/#{@group.key}/
      end
    end
  end
end
