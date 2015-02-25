class DiscussionWrapper
  attr_accessor :discussion
  attr_accessor :discussion_reader

  def initialize(discussion:, discussion_reader:)
    @discussion = discussion
    @discussion_reader = discussion_reader
  end

  def self.new_collection(discussions: [], user: )
    reader_cache = DiscussionReaderCache.new(user: user,
                                             discussions: discussions)
    discussions.map do |discussion|
      DiscussionWrapper.new(discussion: discussion,
                            discussion_reader: reader_cache.get_for(discussion))
    end
  end
end
