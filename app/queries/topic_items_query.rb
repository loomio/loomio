# The API and initial HTML response must select the same authorized activity,
# including unread ranges, focused comments and open polls outside the page.
class TopicItemsQuery
  attr_reader :params, :current_user

  def initialize(topic:, user:, params:)
    @topic = topic
    @current_user = user
    @params = params.with_indifferent_access
    user.ability.authorize!(:show, topic)
  end

  def collection
    records = page_collection(accessible_records)
    if params[:include_polls_not_closed].present?
      records.to_a.union(poll_created_topic_items_not_closed.to_a)
    else
      records
    end
  end

  def order
    %w(sequence_id position position_key).detect {|col| col == params[:order] } || "sequence_id"
  end

  def per
    (params[:limit] || params[:per] || default_page_size).to_i
  end

  def from
    if params[:comment_id]
      TopicItem.where(topic_id: @topic.id)
           .find_by!(kind: "new_comment", itemable_type: "Comment", itemable_id: params[:comment_id])
           .sequence_id
    else
      params[:from] || 0
    end
  end

  def accessible_records
    records = TopicItem.where(topic_id: @topic.id)

    return poll_created_topic_items_not_closed if params[:polls_not_closed].present?

    if params[:unread_or_newest].present?
      if params[:poll_id] || params[:poll_key]
        poll = ModelLocator.new(:poll, params).locate!

        # A poll key can identify a poll embedded inside another topic. In that
        # case the page should open the parent thread at the poll_created topic_item,
        # then include following activity so the surrounding conversation renders.
        if @topic.topicable != poll
          poll_created = records.find_by!(kind: 'poll_created', itemable: poll)
          return records.where("sequence_id >= ?", poll_created.sequence_id).order(:sequence_id)
        end
      end

      reader = TopicReader.for(user: current_user, topic: @topic)
      topic_ranges = @topic.ranges
      unread_ranges = RangeSet.intersect_ranges(reader.unread_ranges, topic_ranges)
      read_ranges = RangeSet.intersect_ranges(reader.read_ranges, topic_ranges)

      if unread_ranges.any?
        if RangeSet.length(unread_ranges) > RangeSet.length(read_ranges)
          records = records.where.not(sequence_id: ranges_for_query(read_ranges)) if read_ranges.any?
          return records.order(:sequence_id)
        else
          return records.where(sequence_id: ranges_for_query(unread_ranges)).order(:sequence_id)
        end
      else
        return records.order(sequence_id: :desc)
      end
    end

    if %w[position_key sequence_id].include?(params[:order_by])
      records = records.order("#{params[:order_by]}#{params[:order_desc] ? " DESC" : ''}")
    else
      records = records.where("#{order} >= ?", from)
    end

    if params[:sequence_id_in]
      ranges = params[:sequence_id_in].split('_').map { |range| range.split('-').map(&:to_i) }.map { |range| range[0]..range[1] }
      records = records.where(sequence_id: ranges)
    end

    if params[:sequence_id_not_in]
      ranges = params[:sequence_id_not_in].split('_').map { |range| range.split('-').map(&:to_i) }.map { |range| range[0]..range[1] }
      records = records.where.not(sequence_id: ranges)
    end

    if params[:pinned] == 'true'
      records = records.where(pinned: true)
    end

    if params[:kind]
      records = records.where("kind in (?)", params[:kind].split(','))
    end

    %w(parent_id depth sequence_id position position_key).each do |name|
      records = records.where(name => params[name]) if params[name]
      records = records.where("#{name} = ?", params["#{name}"]) if params["#{name}"]
      records = records.where("#{name} < ?", params["#{name}_lt"]) if params["#{name}_lt"]
      records = records.where("#{name} > ?", params["#{name}_gt"]) if params["#{name}_gt"]
      records = records.where("#{name} <= ?", params["#{name}_lte"]) if params["#{name}_lte"]
      records = records.where("#{name} >= ?", params["#{name}_gte"]) if params["#{name}_gte"]
      records = records.where("#{name} like ?", params["#{name}_sw"]+"%") if params["#{name}_sw"]
    end
    records
  end

  def page_collection(collection)
    return collection if params[:polls_not_closed].present?

    collection.order(order).limit(per)
  end

  def poll_created_topic_items_not_closed
    TopicItem.where(
      topic_id: @topic.id,
      kind: 'poll_created',
      itemable_type: 'Poll',
      itemable_id: @topic.polls.kept.where(closed_at: nil).select(:id)
    )
  end

  def ranges_for_query(ranges)
    ranges.map { |range| range.first..range.last }
  end

  def default_page_size
    30
  end

end
