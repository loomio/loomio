require 'test_helper'

class ModelLocatorTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
    @discussion = create_discussion(group: @group, author: @user)
  end

  test "finds a model when the param model_id is present" do
    assert_equal @discussion, ModelLocator.new(:discussion, discussion_id: @discussion.id).locate
  end

  test "finds a model when the param model_key is present" do
    assert_equal @discussion, ModelLocator.new(:discussion, discussion_key: @discussion.key).locate
  end

  test "finds a model when the param id is present" do
    assert_equal @discussion, ModelLocator.new(:discussion, id: @discussion.id).locate
  end
end
