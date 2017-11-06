class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :discussion_reader_id,
             :read_items_count,
             :read_salient_items_count,
             :last_read_sequence_id,
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
