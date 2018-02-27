class API::DocumentsController < API::RestfulController

  def for_group
    self.collection = page_collection(for_group_documents).search_for(params[:q])
    respond_with_collection scope: { group_id: @group.id }, serializer: Full::DocumentSerializer
  end

  def for_discussion
    load_and_authorize(:discussion)
    self.collection = Queries::UnionQuery.for(:documents, [
      @discussion.documents,
      @discussion.poll_documents,
      @discussion.comment_documents
    ])
    respond_with_collection
  end

  private

  def for_group_documents
    if current_user.ability.can?(:see_private_content, load_and_authorize(:group))
      private_group_documents
    else
      public_group_documents
    end
  end

  def private_group_documents
    Queries::UnionQuery.for(:documents, [
      @group.documents,
      @group.discussion_documents,
      @group.poll_documents,
      @group.comment_documents ])
  end

  def public_group_documents
    Queries::UnionQuery.for(:documents, [
      @group.documents,
      @group.public_discussion_documents,
      @group.public_poll_documents,
      @group.public_comment_documents ])

  end

  def accessible_records
    (
      load_and_authorize(:group, optional: true)      ||
      load_and_authorize(:discussion, optional: true) ||
      load_and_authorize(:comment, optional: true)    ||
      load_and_authorize(:poll, optional: true)       ||
      load_and_authorize(:outcome)
    ).documents
  end
end
