require "test_helper"

class DevFakeDataHelperTest < ActiveSupport::TestCase
  include Dev::FakeDataHelper

  test "building a comment for an existing parent does not create unrelated records" do
    parent = discussions(:discussion)
    author = users(:user)

    assert_no_difference ["Group.count", "Discussion.count", "User.count"] do
      comment = fake_comment(parent: parent, author: author)
      assert_equal parent, comment.parent
      assert_equal author, comment.author
      assert_not comment.persisted?
    end
  end
end
