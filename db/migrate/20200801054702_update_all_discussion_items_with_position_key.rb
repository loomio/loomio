class UpdateAllDiscussionItemsWithPositionKey < ActiveRecord::Migration[5.2]
  def change
    events_count = Event.where("discussion_id is not null and position_key is null").count

    n = 0
    i = events_count / 1000
    while (n < events_count) do
      PopulateMissingPositionKeysWorker.perform_async(n, 1000)
      n = n + i
    end
  end
end
