class MergeUsersService
  def self.send_merge_verification_email(actor:, target_email:)
    actor.ability.authorize! :update, actor
    target_user = User.active.find_by!(email: target_email)
    prep_for_merge!(source_user: actor)
    hash = build_merge_hash(source_user: actor, target_user: target_user)
    UserMailer.merge_verification(source_user: actor, target_user: target_user, hash: hash).deliver_now
  end

  # Only resets the source (requesting) user's secret_token, not the target's.
  # The target user's secret_token is left untouched so that an attacker cannot
  # disrupt the target's session or password-reset flow simply by calling this
  # endpoint with the victim's email.
  def self.prep_for_merge!(source_user:)
    source_user.update_attribute(:secret_token, User.generate_unique_secure_token)
  end

  def self.validate(source_user:, target_user:, hash:)
    return false if source_user.id == target_user.id
    hash == build_merge_hash(source_user: source_user, target_user: target_user)
  end

  def self.build_merge_hash(source_user:, target_user:)
    sha1 = Digest::SHA1.new
    sha1 << source_user.secret_token
    sha1 << target_user.secret_token
    sha1.hexdigest
  end

  # Invalidate any outstanding merge verification URLs by rotating the source
  # user's secret_token. Called synchronously after a successful merge so the
  # URL cannot be replayed before the async worker redacts the account.
  def self.invalidate_merge!(source_user:)
    source_user.update_attribute(:secret_token, User.generate_unique_secure_token)
  end
end
