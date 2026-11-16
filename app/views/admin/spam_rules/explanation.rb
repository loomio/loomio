class Views::Admin::SpamRules::Explanation < Views::Admin::Base
  def view_template
    panel('What these rules do') do
      p { 'Rules take effect on the next request or job. Only instance admins can manage them.' }
      p do
        strong { 'IP address or network: ' }
        plain 'Denies app access from matching addresses, including signup, sign-in and existing signed-in users. Users receive a 403 response. Accounts and content remain intact and are accessible again from an unblocked IP. The server health check remains available.'
      end
      p do
        strong { 'Email domain: ' }
        plain 'Blocks account creation, sign-in, access by existing signed-in accounts, invitations and delivery to addresses on that complete domain. It does not match subdomains or content mentioning the domain. Accounts and content are retained.'
      end
      p do
        strong { 'Regex: ' }
        plain 'Matches email addresses with the same effects as an email-domain rule. It also rejects matching user names, group names/descriptions and poll titles/details when those records are saved. Patterns are case-insensitive. A regex that exceeds its matching time limit blocks the value; the test result reports the timeout. The imported SPAM_REGEX retains its existing coverage.'
      end
      p { 'Activity counts blocked actions, not distinct people. Repeated requests from one bot increase the totals. Signups, sign-ins, access requests, invitations, suppressed emails and content checks are shown separately. Totals use minute buckets, are retained for 30 days and have one-minute precision. Test values do not increase activity counts.' }
      p { 'Disabling or expiring a rule removes its restrictions. Disabling preserves its activity and change history. Editing a pattern keeps the same rule history and activity totals.' }
    end
  end
end
