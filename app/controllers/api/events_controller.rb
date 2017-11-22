class API::EventsController < API::RestfulController
  include UsesDiscussionReaders

  private

  def order
    %w(sequence_id position id created_at).detect {|col| col == params[:order] } || "sequence_id"
  end

  def accessible_records
    records = load_and_authorize(:discussion).items.
              includes(:user, :discussion, :eventable, parent: [:user, :eventable]).uniq

    records = records.where('sequence_id >= ?', sequence_id_for(records)) if (params[:comment_id] || params[:from])

    %w(parent_id depth sequence_id position).each do |name|
      records = records.where(name => params[name]) if params[name]
      records = records.where("#{name} >= ?", params["min_#{name}"]) if params["min_#{name}"]
      records = records.where("#{name} <= ?", params["max_#{name}"]) if params["max_#{name}"]
      # in future, could add support for "exclude_#{name}s" with ranges or arrays
    end
    records
  end

  def page_collection(collection)
    collection.order(order).limit(params[:per] || default_page_size)
  end

  def default_page_size
    30
  end

  def sequence_id_for(collection)
    sequence_id_for_comment(collection) || params[:from].to_i
  end

  def sequence_id_for_comment(collection)
    collection.find_by(eventable_type: "Comment", eventable_id: params[:comment_id]).try(:sequence_id)
  end

  # we always want to serialize out events in the events controller
  alias :events_to_serialize :resources_to_serialize

  # events will define their own serializer through the `active_model_serializer` method
  def resource_serializer
    nil
  end
end
