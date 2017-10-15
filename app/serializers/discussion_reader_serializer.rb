class DiscussionReaderSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id,
             :discussion_reader_id,
             :read_sequence_id_ranges,
             :read_items_count,
             :last_read_at

  def id
    object.discussion_id
  end

   def discussion_reader_id
     object.id
   end
end
