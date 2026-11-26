class Api::V1::AttachmentsController < Api::V1::RestfulController
  def index
    group_ids = if params[:group_id].present?
      group = current_user.groups.find_by!(id: params[:group_id])
      case params[:subgroups]
      when 'mine', 'all'
        [ group.id ] | (current_user.group_ids & group.id_and_subgroup_ids)
      else
        [ group.id ]
      end
    else
      current_user.group_ids
    end
    limit = params[:limit] || params[:per] || 20
    offset = params[:offset] || params[:from] || 0
    self.collection = AttachmentQuery.find(group_ids, params[:q], limit, offset, user: current_user)
    self.collection_count = AttachmentQuery.count(group_ids, params[:q], user: current_user)
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
