class MergeUsersService
  def self.send_merge_verification_email(actor:, target_email:)
    actor.ability.authorize! :update, actor
    target_user = User.active.find_by!(email: target_email)
    hash = build_merge_hash(source_user: actor, target_user: target_user)
    UserMailer.merge_verification(source_user: actor, target_user: target_user, hash: hash).deliver_now
  end

  def self.validate(source_user:, target_user:, hash:)
    return false if source_user.id == target_user.id

    source_user == User.find_signed(hash, purpose: merge_purpose(target_user))
  end

  def self.build_merge_hash(source_user:, target_user:)
    source_user.signed_id(purpose: merge_purpose(target_user))
  end

  # Mark the source account inactive before the async migration runs, so the
  # verification URL cannot be submitted repeatedly while the worker is queued.
  def self.invalidate_merge!(source_user:)
    source_user.update_attribute(:deactivated_at, Time.current)
  end

  def self.merge_purpose(target_user)
    "merge_user_into:#{target_user.id}"
  end
end
