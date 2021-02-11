class API::V1::TagsController < API::V1::RestfulController
  def index
    instantiate_collection { |collection| collection.where(group: load_and_authorize(:group)) }
    respond_with_collection
  end

  def priority
    @group = load_and_authorize(:group)

    Array(params[:ids]).each_with_index do |id, index|
      Tag.where(id: id, group_id: @group.id).update_all(priority: index)
    end

    instantiate_collection

    # rember to live update too
    respond_with_collection
  end

  private

  def accessible_records
    Tag.where(group_id: @group.id)
  end
end
