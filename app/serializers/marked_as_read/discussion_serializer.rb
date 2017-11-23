class MarkedAsRead::DiscussionSerializer < ActiveModel::Serializer
  embed :ids, include: true

  def self.attributes_from_reader(*attrs)
    attrs.each do |attr|
      case attr
      when :discussion_reader_id then define_method attr, -> { reader.id }
      else                            define_method attr, -> { reader.send(attr) }
      end
      define_method :"include_#{attr}?", -> { reader.present? }
    end
    attributes *attrs
  end

  attributes :id,
             :key,
             :items_count,
             :ranges

  attributes_from_reader :discussion_reader_id,
                         :read_ranges,
                         :last_read_at,
                         :dismissed_at

   def reader
     @reader ||= scope[:reader_cache].get_for(object) if scope[:reader_cache]
   end

   def scope
     super || {}
   end
end
