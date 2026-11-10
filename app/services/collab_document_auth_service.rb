# Decides whether a collaborative-editing client may join a document.
#
# Document names are "<record type>-<record id or new>-..." as built by
# collabKey in the Vue client; for new records the third part is the creating
# user's id. Signed-out visitors may only edit a new group. Signed-in users may
# edit their own new records and existing records they can update.
class CollabDocumentAuthService
  RECORD_TYPES = %w[comment discussion poll stance outcome pollTemplate discussionTemplate group user].freeze

  # `user` is an active User, or nil for a signed-out visitor.
  def self.authorized?(user:, document_name:)
    record_type, record_id, user_id_if_new = document_name.to_s.split('-')
    return false unless RECORD_TYPES.include?(record_type)
    return record_type == 'group' && record_id == 'new' if user.nil?

    if record_id == 'new'
      user_id_if_new.to_i == user.id
    else
      record = record_type.camelize.constantize.find_by(id: record_id.to_i)
      record.present? && user.can?(:update, record)
    end
  end

  # The active user of the session cookie on a Rack request, or nil. Matches
  # how Action Cable identifies users (ApplicationCable::Connection).
  def self.user_from_session(env)
    session_id = ActionDispatch::Request.new(env).cookie_jar.signed[:session_id]
    return if session_id.blank?

    user = Session.active.includes(:user).find_by(id: session_id)&.user
    user if user&.active?
  end
end
