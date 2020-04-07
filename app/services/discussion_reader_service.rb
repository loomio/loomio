class DiscussionReaderService
  def self.redeem(discussion_reader: , actor: )
    actor.ability.authorize! :redeem, discussion_reader
    discussion_reader.update(user: actor, accepted_at: Time.zone.now)
  end
end
