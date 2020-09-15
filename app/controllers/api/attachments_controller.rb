class API::AttachmentsController < API::RestfulController
  def index
    instantiate_collection do |collection|
      collection.where(group_id: params[:group_id])
    end
    respond_with_collection
  end

  def accessible_records
    ActiveStorage::Attachment.includes(:blob).where(group_id: current_user.group_ids, name: "files")
  end

  def destroy
    attachment = load_and_authorize :attachment, :destroy
    record = attachment.record
    attachment.purge_later
    # record.build_attachments
    record.save!
    serializer = "#{record.class.to_s}Serializer".constantize
    render json: serializer.new(record).as_json
  end
end
