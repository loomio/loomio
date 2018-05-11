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
      .find_each(batch_size: 250) { |d| Membership.import(memberships_for_discussion(d)) }
  end

  def memberships_for_discussion(discussion)
    Event.where(discussion_id: discussion.id)
         .where.not(user_id: discussion.guest_group.member_ids)
         .select("user_id, #{discussion.guest_group_id} as group_id, min(created_at) as accepted_at")
         .group(:user_id, :discussion_id)
         .map { |item| Membership.new(item.as_json) }
  end
end
