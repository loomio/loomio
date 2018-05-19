class DiscussionForker
  attr_accessor :source, :target

  def initialize(source, target)
    @source = source
    @target = target
  end

  def fork!
    move_items
    update_counts
    move_readers
  end

  private

  def move_items
    target.forked_items.update_all(discussion_id: target.id)
    target.forked_items.where(depth: 1).update_all(parent_id: target.created_event.id)
  end

  def update_counts
    Event.reorder_with_parent_id(target.created_event.id)
    target.update_sequence_info!
    target.update_items_count
  end

  def move_readers
    #the author has by default the ranges of the target discussion
    target.discussion_readers
          .find_by(user:target.author)
          .update(read_ranges_string: target.ranges_string)

    #other participants have readers created for them based on the intersection of thier prior range and the new discussions ranges
    readers = source.discussion_readers.where.not(user:target.author).map do |reader|
      target.discussion_readers.build(user: reader.user, read_ranges: RangeSet.intersect_ranges(target.ranges, reader.read_ranges))
    end
    DiscussionReader.import(readers)
  end
end
