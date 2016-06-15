class DiscussionVersionService
  attr_reader :discussion, :previous_ids

  def initialize(discussion:, new_version:)
    @discussion   = discussion
    @previous_ids = discussion.attachment_ids
    @new_version  = new_version
  end

  def handle_version_update!
    return unless previous_ids != discussion.attachment_ids
    discussion.attachments.where('id NOT IN (?)', discussion.attachment_ids).destroy_all
    discussion_version.object_changes['attachment_ids'] = [previous_ids, discussion.attachment_ids]
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
