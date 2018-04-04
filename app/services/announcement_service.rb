class AnnouncementService
  def self.create(model:, params:, actor:)
    actor.ability.authorize! :announce, model

    recipients = User.where(id: [
      params[:recipients][:user_ids],
      User.import(params[:recipients][:emails].map { |e| User.new(email: e) }).ids
    ].compact.flatten)

    memberships = recipients.where.not(id: model.guest_group.member_ids).map do |user|
      Membership.new(inviter: actor, user: user, group: model.guest_group)
    end
    Membership.import(memberships)

    recipient_memberships = model.guest_group.memberships.where(user: recipients)

    Events::AnnouncementCreated.bulk_publish! model, actor, recipient_memberships, params
  end
end
