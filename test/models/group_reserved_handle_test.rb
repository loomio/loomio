require 'test_helper'

class GroupReservedHandleTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @hex = SecureRandom.hex(4)
  end

  teardown do
    Group.instance_variable_set(:@reserved_handles, nil)
  end

  def with_reserved(*handles, &block)
    Group.stub(:reserved_handles, handles.to_set, &block)
  end

  test "reads one handle per line, ignoring blanks and comments" do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "public"))
      File.write(File.join(dir, "public/reserved-group-handles.txt"), "# website paths\nfr\n\n Pricing \n")
      Group.instance_variable_set(:@reserved_handles, nil)
      Rails.stub(:root, Pathname.new(dir)) do
        assert_equal Set["fr", "pricing"], Group.reserved_handles
      end
    end
  end

  test "reserves nothing when the website file is absent" do
    Dir.mktmpdir do |dir|
      Group.instance_variable_set(:@reserved_handles, nil)
      Rails.stub(:root, Pathname.new(dir)) do
        assert_empty Group.reserved_handles
      end
    end
  end

  test "rejects a reserved handle on a new group" do
    with_reserved("fr") do
      group = Group.new(name: "French group", handle: "fr", group_privacy: 'secret')
      assert_not group.valid?
      assert group.errors.of_kind?(:handle, :taken)
    end
  end

  test "rejects renaming a group to a reserved handle" do
    group = Group.create!(name: "Rename #{@hex}", handle: "rename-#{@hex}", group_privacy: 'secret')
    group.add_admin!(@user)
    with_reserved("pricing") do
      assert_raises(ActiveRecord::RecordInvalid) do
        GroupService.update_handle(group: group, handle: "pricing", actor: @user)
      end
    end
    assert_equal "rename-#{@hex}", group.reload.handle
  end

  test "allows ordinary handles" do
    with_reserved("fr") do
      group = Group.new(name: "Ordinary", handle: "ordinary-#{@hex}", group_privacy: 'secret')
      assert group.valid?
    end
  end

  test "a group already holding a reserved handle can still be saved" do
    group = Group.create!(name: "Legacy #{@hex}", handle: "legacy-#{@hex}", group_privacy: 'secret')
    group.update_column(:handle, "legacy-reserved-#{@hex}")
    with_reserved("legacy-reserved-#{@hex}") do
      group.name = "Legacy renamed #{@hex}"
      assert group.save
    end
  end

  test "suggest_handle skips reserved handles" do
    with_reserved("de-#{@hex}") do
      assert_equal "de-#{@hex}-1", GroupService.suggest_handle(name: "de #{@hex}", parent_handle: nil)
    end
  end
end
