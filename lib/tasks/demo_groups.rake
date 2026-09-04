namespace :loomio do
  desc "Provision a code-backed demo group for USER_EMAIL (DEMO_TEMPLATE defaults to mobile)"
  task provision_demo_group: :environment do
    email = ENV.fetch("USER_EMAIL")
    template_key = ENV.fetch("DEMO_TEMPLATE", "mobile")
    user = User.find_by!("lower(email) = ?", email.downcase)

    result = DemoGroupTemplateService.create!(template_key: template_key, user: user)
    polls_to_vote_on = result.polls.values.count do |poll|
      stance = poll.stances.latest.find_by(participant: user)
      poll.active? && stance && stance.cast_at.nil? && user.ability.can?(:vote_in, poll)
    end
    puts({
      group_id: result.group.id,
      group_url: Rails.application.routes.url_helpers.group_url(result.group, host: ENV.fetch("CANONICAL_HOSTNAME")),
      polls_to_vote_on: polls_to_vote_on,
      unread_notifications: result.notifications.length
    }.to_json)
  end
end
