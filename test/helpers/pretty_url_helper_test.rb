require 'test_helper'

class PrettyUrlHelperTest < ActionView::TestCase
  include PrettyUrlHelper

  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
  end

  test "gives normal group url for group without handle" do
    group = Group.create!(name: "No Handle #{SecureRandom.hex(4)}")
    group.update_column(:handle, nil)
    assert_includes group_url(group), group.key
  end

  test "gives group handle url" do
    assert_includes group_url(@group), @group.handle
  end

  test "supports handles for subgroup urls" do
    subgroup = groups(:subgroup)
    assert_includes group_url(subgroup), subgroup.handle
  end
end
