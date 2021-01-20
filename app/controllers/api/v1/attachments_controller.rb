class API::V1::AttachmentsController < API::V1::RestfulController
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
    record.save!
    serializer = "#{record.class.to_s}Serializer".constantize
    root = record.class.to_s.pluralize.underscore
    self.collection = [record]
    render json: resources_to_serialize, scope: default_scope, each_serializer: serializer, root: root
  end

  def serializer_class
    AttachmentSerializer
  end

  def serializer_root
    'attachments'
  end
end
