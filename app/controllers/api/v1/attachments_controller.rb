class API::V1::AttachmentsController < API::V1::RestfulController
  def index
    # Group.find_by(params[:group_id).id_and_subgroup_ids
    group = current_user.groups.find_by!(id: params[:group_id])
    instantiate_collection do |collection|
      AttachmentQuery.find(group.id_and_subgroup_ids, params[:q])
    end
    respond_with_collection
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

  def serializer_root
    :attachments
  end

  def serializer_class
    AttachmentSerializer
  end

  def accessible_records
    AttachmentQuery
  end

  def serializer_root
    'attachments'
  end
end
