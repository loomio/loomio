class API::DocumentsController < API::RestfulController

  def for_group
    load_and_authorize(:group)
    self.collection = page_collection Queries::UnionQuery.for(:documents,
      @group.documents,
      @group.discussion_documents,
      @group.poll_documents,
      @group.comment_documents
    ).search_for(params[:q])
    respond_with_collection scope: { group_id: @group.id }
  end

  private

  def accessible_records
    (load_and_authorize(:discussion, optional: true) || load_and_authorize(:group)).documents
  end
end
