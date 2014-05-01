class DiscussionReaderCache
  attr_accessor :user
  attr_accessor :readers

  def initialize(user, readers)
    @user = user
    @readers = readers
    @readers_by_discussion_id = {}
    @readers.each do |reader|
      @readers_by_discussion_id[reader.discussion_id] = reader
    end
  end

  def get_for(discussion)
    @readers_by_discussion_id.fetch(discussion.id) { new_reader_for(discussion) }
  end

  private

  def new_reader_for(discussion)
    dr = DiscussionReader.new
    dr.discussion = discussion
    dr.user = user
    dr
  end
end
