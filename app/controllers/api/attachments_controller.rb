class API::AttachmentsController < API::RestfulController
  def index
    instantiate_collection do |collection|
      collection.where(group_id: params[:group_id])
    end
    respond_with_collection
  end

  def accessible_records
     ActiveStorage::Attachment.where(group_id: current_user.group_ids)
  end
end
