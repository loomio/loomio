class API::DocumentsController < API::RestfulController

  def for_group
    self.collection = page_collection records_for_group
    respond_with_collection
  end

  private

  def accessible_records
    (load_and_authorize(:discussion, optional: true) || load_and_authorize(:group)).documents
  end

  def records_for_group
    load_and_authorize(:group)
    Queries::UnionQuery.for(:documents,
      @group.documents,
      @group.discussion_documents,
      @group.poll_documents,
      @group.comment_documents
    ).search_for(params[:q])
  end
end
