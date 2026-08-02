require 'test_helper'

class PrettyUrlHelperTest < ActionView::TestCase
  include PrettyUrlHelper

  setup do
    @user = users(:user)
    @group = groups(:group)
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

  test "returns nil path when model has no url" do
    assert_nil polymorphic_path(nil)
  end

  test "returns the group email path for a received email" do
    received_email = ReceivedEmail.new(group: @group)

    assert_equal group_emails_url(@group.key), polymorphic_url(received_email)
  end

  test "returns nil for a received email whose group has been cleared" do
    event = Event.new(kind: "unknown_sender", eventable: ReceivedEmail.new)

    assert_nil event.notification_url
  end
end
