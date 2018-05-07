class BackfillDiscussionMembersJob
  def perform
    run_for_timeframe(since: 1.week.ago) # discussions updated in the last week
    run_for_timeframe(since: 1.month.ago) # discussions updated in the last month
    run_for_timeframe(since: 3.months.ago) # discussions updated in the last 3 months
    run_for_timeframe(till: 3.months.ago + 2.days) # all discussions except those in the last 3 months
    #                                  ^^ (2 days to account for the time it takes to run the first 3 jobs)
  end

  def run_for_timeframe(since: 10.years.ago, till: 1.year.from_now)
    Discussion
      .includes(:items)
      .within(since, till, :last_activity_at)
      .where.not(author_id: User.helper_bot.id)
      .find_each(batch_size: 250) do |d|
      to_import = d.items
                   .where.not(user_id: d.guest_group.member_ids)
                   .map do |item|
        Membership.new(group_id: d.guest_group_id, user_id: item.user_id, accepted_at: item.created_at)
      end
      Membership.import(to_import) if to_import.any?
    end
  end
end
