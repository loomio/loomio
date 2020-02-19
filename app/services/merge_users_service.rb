class MergeUsersService
  def self.send_merge_verification_email(actor:, target_email:)
    actor.ability.authorize! :update, actor
    target_user = User.active.find_by!(email: target_email)
    prep_for_merge!(source_user: actor, target_user: target_user)
    hash = MergeUsersService.build_merge_hash(source_user: actor, target_user: target_user)
    UserMailer.merge_verification(source_user: actor, target_user: target_user, hash: hash).deliver_now
  end

  def self.prep_for_merge!(source_user:, target_user:)
    source_user.update_attribute(:reset_password_token, User.generate_unique_secure_token)
    target_user.update_attribute(:reset_password_token, User.generate_unique_secure_token)
  end

  def self.validate(source_user:, target_user:, hash:)
    return false if source_user.id == target_user.id
    hash == build_merge_hash(source_user: source_user, target_user: target_user)
  end

  def self.build_merge_hash(source_user:, target_user:)
    sha1 = Digest::SHA1.new
    sha1 << source_user.reset_password_token
    sha1 << target_user.reset_password_token
    sha1.hexdigest
  end
end
