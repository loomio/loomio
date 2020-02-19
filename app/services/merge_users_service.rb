class MergeUsersService
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
