# Calendar providers fetch these URLs without a browser session. The token is
# read-only, per membership, and never authorizes votes or other account access.
class CalendarFeedsController < ActionController::Base
  def show
    response.cache_control.replace(no_store: true)
    response.headers['Referrer-Policy'] = 'no-referrer'
    response.headers['X-Robots-Tag'] = 'noindex, nofollow'
    subscription = CalendarSubscription.includes(membership: [:user, :group]).find_by!(token: params[:token])
    return head :not_found unless subscription.available?

    calendar = GroupCalendarService.new(group: subscription.group, user: subscription.user,
      starts_at: 30.days.ago, ends_at: 1.year.from_now)
    I18n.with_locale(subscription.user.locale) do
      send_data calendar.to_ical, type: 'text/calendar; charset=UTF-8', disposition: 'inline', filename: 'group.ics'
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
