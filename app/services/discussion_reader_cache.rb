class DiscussionReaderCache
  attr_accessor :user
  attr_accessor :readers

  def initialize(user: nil, discussions: [])
    @user = user
    @readers_by_discussion_id = {}

    if user
      @readers = DiscussionReader.where(user_id: user.id,
                                        discussion_id: discussions.map(&:id)).includes(:discussion)
    else
      @readers = []
    end

    @readers.each do |reader|
      @readers_by_discussion_id[reader.discussion_id] = reader
    end
  end

  def get_for(discussion)
    @readers_by_discussion_id.fetch(discussion.id) { new_reader_for(discussion) }
  end

  private

  def new_reader_for(discussion)
    DiscussionReader.new do |dr|
      dr.discussion = discussion
      dr.user = user
    end
  end
end
