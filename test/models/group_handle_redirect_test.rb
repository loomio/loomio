require 'test_helper'

class GroupHandleRedirectTest < ActiveSupport::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "ghruser#{hex}", email: "ghruser#{hex}@example.com", username: "ghruser#{hex}", email_verified: true)
    @group = Group.create!(name: "GHR Group #{hex}", handle: "ghrgroup-#{hex}", group_privacy: 'secret')
    @group.add_admin!(@user)
    @other_group = Group.create!(name: "GHR Other #{hex}", handle: "ghrother-#{hex}", group_privacy: 'secret')
    @other_group.add_admin!(@user)
  end

  test "changing a group handle creates a retired handle" do
    old_handle = @group.handle

    assert_difference 'GroupHandleRedirect.count', 1 do
      GroupService.update_handle(group: @group, handle: "ghr-new-handle-#{SecureRandom.hex(4)}", actor: @user)
    end

    assert_equal old_handle, GroupHandleRedirect.last.handle
    assert_equal @group.id, GroupHandleRedirect.last.group_id
  end

  test "changing handle twice keeps both old handles but limit is 3" do
    first_handle = @group.handle

    GroupService.update_handle(group: @group, handle: "ghr-second-#{SecureRandom.hex(4)}", actor: @user)
    second_handle = @group.reload.handle

    GroupService.update_handle(group: @group, handle: "ghr-third-#{SecureRandom.hex(4)}", actor: @user)

    assert GroupHandleRedirect.exists?(handle: first_handle, group_id: @group.id)
    assert GroupHandleRedirect.exists?(handle: second_handle, group_id: @group.id)
    assert_equal 2, @group.handle_redirects.count
  end

  test "limits redirects to most recent 3" do
    first_handle = @group.handle

    GroupService.update_handle(group: @group, handle: "ghr-a-#{SecureRandom.hex(4)}", actor: @user)
    GroupService.update_handle(group: @group, handle: "ghr-b-#{SecureRandom.hex(4)}", actor: @user)
    GroupService.update_handle(group: @group, handle: "ghr-c-#{SecureRandom.hex(4)}", actor: @user)
    GroupService.update_handle(group: @group, handle: "ghr-d-#{SecureRandom.hex(4)}", actor: @user)

    # first_handle (oldest) should have been trimmed
    refute GroupHandleRedirect.exists?(handle: first_handle, group_id: @group.id)
    assert_equal 3, @group.handle_redirects.count
  end

  test "cannot set a group handle to another group's retired handle" do
    old_handle = @other_group.handle
    GroupService.update_handle(group: @other_group, handle: "ghr-other-new-#{SecureRandom.hex(4)}", actor: @user)

    # old_handle is now retired by other_group
    @group.handle = old_handle
    refute @group.valid?
    assert_includes @group.errors[:handle], 'has already been taken'
  end

  test "cannot set a group handle to another group's current handle" do
    @group.handle = @other_group.handle
    refute @group.valid?
    assert_includes @group.errors[:handle], 'has already been taken'
  end

  test "cannot create duplicate retired handles for the same group" do
    old_handle = @group.handle
    GroupService.update_handle(group: @group, handle: "ghr-dup-new-#{SecureRandom.hex(4)}", actor: @user)

    redirect = GroupHandleRedirect.new(group: @group, handle: old_handle)
    refute redirect.valid?
  end

  test "cannot create a redirect with the group's current handle" do
    redirect = GroupHandleRedirect.new(group: @group, handle: @group.handle)
    refute redirect.valid?
    assert_includes redirect.errors[:handle], 'has already been taken'
  end

  test "cannot create a redirect with another group's current handle" do
    redirect = GroupHandleRedirect.new(group: @group, handle: @other_group.handle)
    refute redirect.valid?
    assert_includes redirect.errors[:handle], 'has already been taken'
  end

  test "parameterizes the handle before saving" do
    old_handle = @group.handle
    GroupService.update_handle(group: @group, handle: "ghr-param-new-#{SecureRandom.hex(4)}", actor: @user)

    redirect = GroupHandleRedirect.create!(group: @group, handle: "  Has Spaces and CAPS  ")
    assert_equal "has-spaces-and-caps", redirect.handle
  end

  test "handle suggestions avoid retired handles" do
    old_handle = @group.handle
    GroupService.update_handle(group: @group, handle: "ghr-suggest-new-#{SecureRandom.hex(4)}", actor: @user)

    suggestion = GroupService.suggest_handle(name: old_handle, parent_handle: nil)
    refute_equal old_handle, suggestion
  end

  test "belongs_to group is destroyed with group" do
    old_handle = @group.handle
    GroupService.update_handle(group: @group, handle: "ghr-cascade-new-#{SecureRandom.hex(4)}", actor: @user)

    assert_difference 'GroupHandleRedirect.count', -1 do
      @group.destroy
    end
  end
end
