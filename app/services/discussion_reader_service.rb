class DiscussionReaderService
  def self.redeem(discussion_reader: , actor: )
    return unless DiscussionReader.redeemable_by(actor).where(id: discussion_reader.id).exists?
    discussion_reader.update(user: actor, accepted_at: Time.zone.now)
  rescue ActiveRecord::RecordNotUnique
    DiscussionReader.find_by(discussion_id: discussion_reader.discussion_id,
                            user_id: actor.id).
                    update(inviter_id: discussion_reader.inviter_id,
                           accepted_at: Time.zone.now)
    discussion_reader.destroy
  end
end
