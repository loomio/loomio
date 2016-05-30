module HasAttachments
  extend ActiveSupport::Concern

  included do
    has_many :attachments, as: :attachable, dependent: :destroy
    validate :attachments_owned_by_author
    attr_accessor :new_attachment_ids
  end

  def attachments_owned_by_author
    return if attachments.pluck(:user_id).select { |user_id| user_id != user.id }.empty?
    errors.add(:attachments, "Attachments must be owned by author")
  end

end
