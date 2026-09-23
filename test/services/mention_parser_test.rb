require 'test_helper'

class MentionParserTest < ActiveSupport::TestCase
  test "extracts Loomio usernames from Markdown" do
    text = "Hello @one, @two_name, and @three-name"

    assert_equal %w[one two_name three-name], MentionParser.usernames(text)
  end

  test "normalizes and deduplicates usernames" do
    assert_equal ['some-one'], MentionParser.usernames('@Some-One and @some-one')
  end

  test "does not extract usernames from email addresses" do
    assert_empty MentionParser.usernames('Contact person@example.org')
  end

  test "treats a trailing hyphen as punctuation" do
    assert_equal ['someone'], MentionParser.usernames('Thanks @someone-')
  end
end
