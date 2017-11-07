class RecalculateReadItemsCountsJob < ActiveJob::Base
  queue_as :low_priority
  def perform(discussion)
    DiscussionReader.where(discussion: discussion.id).find_each do |dr|
      dr.update_attribute(:read_items_count, dr.calculate_read_items_count)
    end
  end
end
