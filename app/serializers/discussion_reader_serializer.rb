class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :discussion_reader_id,
             :read_ranges_string,
             :last_read_at,
             :seen_by_count


  def id
    object.discussion_id
  end

   def discussion_reader_id
     object.id
   end

   def seen_by_count
     object.discussion.seen_by_count
   end
end
