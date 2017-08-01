namespace :loomio do
  task visitors_to_users: :environment do
    # for each poll, get visitors and add them to the guest group
    Poll.find_each(batch_size: 100) do |poll|
      PollService.convert_visitors(poll: poll)
    end
  end
end
