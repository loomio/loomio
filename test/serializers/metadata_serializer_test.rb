require 'test_helper'

class MetadataSerializerTest < ActiveSupport::TestCase
  def description_for(text, format = 'html')
    discussion = Discussion.new(description: text, description_format: format)
    Metadata::DiscussionSerializer.new(discussion).description
  end

  test 'thread previews omit headings and preserve spaces between blocks and line breaks' do
    html = '<h2>Context</h2><p>Clear <strong>group</strong> responsibilities.</p>' \
      '<h3>Background</h3><p>Work together.<br>Decide &amp; act.</p>'

    assert_equal 'Clear group responsibilities. Work together. Decide & act.', description_for(html)
  end

  test 'markdown headings are omitted while the same word in a paragraph is retained' do
    text = "## Context\n\nContext matters to **our group**.\n\nA second paragraph."

    assert_equal 'Context matters to our group. A second paragraph.', description_for(text, 'md')
  end

  test 'discussion and poll descriptions use bounded excerpts without changing their content' do
    text = '<h2>Context</h2><p>' + ('Useful information for our group. ' * 30) + '</p>'
    discussion = Discussion.new(description: text, description_format: 'html')
    poll = Poll.new(details: text, details_format: 'html')
    [Metadata::DiscussionSerializer.new(discussion), Metadata::PollSerializer.new(poll)].each do |serializer|
      excerpt = serializer.description
      assert_operator excerpt.length, :<=, 200
      assert excerpt.start_with?('Useful information for our group.')
      assert excerpt.end_with?('...')
      refute_includes excerpt, 'Context'
    end
    assert_equal text, discussion.description
    assert_equal text, poll.details
  end

  test 'missing content and headings without body text produce empty excerpts' do
    [nil, '', '<h1>Context</h1><p></p>'].each do |text|
      assert_equal '', description_for(text)
    end
  end
end
