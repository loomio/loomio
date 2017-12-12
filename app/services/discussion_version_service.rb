class DiscussionVersionService
  attr_reader :discussion, :previous_ids

  def initialize(discussion:, new_version:)
    @discussion   = discussion
    @previous_ids = discussion.document_ids
    @new_version  = new_version
  end

  def handle_version_update!
    return unless previous_ids != discussion.document_ids
    discussion.documents.where('id NOT IN (?)', discussion.document_ids).destroy_all
    discussion_version.object_changes['document_ids'] = [previous_ids, discussion.document_ids]
    discussion_version.save
  end

  private

  def discussion_version
    @discussion_version ||= if @new_version
      discussion.versions.build(event: :update, object_changes: {})
    else
      discussion.versions.last
    end
  end

end
