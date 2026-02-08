# frozen_string_literal: true

class Views::Web::Help::Api < Views::Web::BasicLayout
  def initialize(api_key:, group_id:, email:, root_url:, **layout_args)
    super(**layout_args)
    @api_key = api_key
    @group_id = group_id
    @email = email
    @root_url = root_url
  end

  def view_template
    main(class: "container") do
      h1 { plain "Loomio API" }

      p do
        plain "Hi! We've created this API for people who are writing integrations for Loomio. At this stage it's still new and development is request driven - meaning that if you want to see a new feature, please "
        a(href: "https://www.loomio.org/community-product-development/", target: "_blank") { plain "join the product development group" }
        plain " and explain what you would like to do."
      end

      p(class: "mt-4 mb-4") { plain "Your API key is: #{@api_key}" }

      h2 { plain "create discussion" }
      h3 { plain "example" }
      pre { plain "curl -X POST -H 'Content-Type: application/json' -d '{\"group_id\": #{@group_id}, \"title\":\"example thread\", \"recipient_emails\":[\"#{@email}\"], \"api_key\": \"#{@api_key}\"}' #{@root_url}api/b1/discussions" }

      h3 { plain "params" }
      render_discussion_params

      h2 { plain "show discussion" }
      p { plain "Fetch a discussion using the discussion id (an integer) or key (a string) using the following request format" }
      h3 { plain "example" }
      pre { plain "curl #{@root_url}api/b1/discussions/aBcD123?api_key=#{@api_key}" }

      h2 { plain "create poll" }
      h3 { plain "example" }
      closing_at = 7.days.from_now.at_beginning_of_hour.utc.iso8601
      pre { plain "curl -X POST -H 'Content-Type: application/json' -d '{\"title\":\"example poll\", \"poll_type\": \"proposal\", \"options\": [\"agree\", \"disagree\"], \"closing_at\": \"#{closing_at}\", \"recipient_emails\":[\"#{@email}\"], \"api_key\": \"#{@api_key}\"}' #{@root_url}api/b1/polls" }

      h3 { plain "params" }
      render_poll_params(closing_at)

      h2 { plain "show poll" }
      p { plain "Fetch a poll using the poll id (an integer) or key (a string)" }
      h3 { plain "example" }
      pre { plain "curl #{@root_url}api/b1/polls/aBcD123?api_key=#{@api_key}" }

      h2 { plain "list memberships" }
      url = "#{@root_url}api/b1/memberships?api_key=#{@api_key}"
      a(href: url) { plain url }
      pre { plain "curl -d 'api_key=#{@api_key}' #{@root_url}api/b1/memberships" }

      h2 { plain "manage memberships" }
      p { plain "send a list of emails. it will invite all the new email addresses to the group." }
      pre { plain "curl -X POST -H 'Content-Type: application/json' -d '{\"emails\":[\"person@example.com\"], \"api_key\": \"#{@api_key}\"}' #{@root_url}api/b1/memberships" }

      p do
        plain "if you pass remove_absent=1 then any members of the group who were not included in the list will be removed from the group. "
        b { plain "be careful, you could remove everyone in your group!" }
      end
      pre { plain "curl -X POST -H 'Content-Type: application/json' -d '{\"emails\":[\"person@example.com\"], \"remove_absent\": 1, \"api_key\": \"#{@api_key}\"}' #{@root_url}api/b1/memberships" }

      h3 { plain "params" }
      table do
        tr { td { plain "emails" }; td { plain "array of strings. required. email addresses of people to invite into the group" } }
        tr { td { plain "remove_absent" }; td { plain "boolean. If true, remove anyone from the group who's email is not present in the list" } }
      end
      p { plain 'this returns an object with {added_emails: ["person@added.com"], removed_emails: ["person@removed.com"]}.' }
    end
  end

  private

  def render_discussion_params
    table do
      tr { td { plain "title" }; td { plain "title of the thread (required)" } }
      tr { td { plain "description" }; td { plain "context for the thread (optional)" } }
      tr { td { plain "description_format" }; td { plain "string. either 'md' or 'html' (optional, default: md)" } }
      tr { td { plain "recipient_audience" }; td { plain "string 'group' or null. if 'group' whole group will be notified about the new thread (optional)" } }
      tr { td { plain "recipient_user_ids" }; td { plain "array of user ids to notify or invite to the thread (optional)" } }
      tr { td { plain "recipient_emails" }; td { plain "array of email addresses of people to invite to the thread (optional)" } }
      tr { td { plain "recipient_message" }; td { plain "string. message to include in the email invitation (optional)" } }
    end
  end

  def render_poll_params(closing_at)
    table do
      tr { td { plain "title" }; td { plain "string. required. title of the poll" } }
      tr { td { plain "poll_type" }; td { plain "string. required. values: 'proposal', 'poll', 'count', 'score', 'ranked_choice', 'meeting', 'dot_vote'" } }
      tr { td { plain "details" }; td { plain "string. optional. the body text of the poll" } }
      tr { td { plain "details_format" }; td { plain "string. optional. default: md. values: 'md' or 'html'." } }
      tr { td { plain "options" }; td { plain "array of strings. If poll_type is proposal then valid values are 'agree', 'disagree', 'abstain', 'block'. If poll_type is meeting then provide iso8601 date or datetime strings. For all other poll_types, any string is valid." } }
      tr { td { plain "closing_at" }; td { plain "iso8601 string or null. default: null. Specify when the poll closes with an iso8601 string such as '#{closing_at}'. If null then voting is disabled and poll is considered \"Work in progress\"." } }
      tr { td { plain "specified_voters_only" }; td { plain "boolean. optional. default: false. true: only specified people can vote, false: everyone in the group will be invited to vote" } }
      tr { td { plain "hide_results" }; td { plain "string. optional. default: 'off'. values: 'off', 'until_vote', 'until_closed'. allow voters to see the results before the poll has closed" } }
      tr { td { plain "shuffle_options" }; td { plain "boolean. default false. display options to voters in random order." } }
      tr { td { plain "anonymous" }; td { plain "boolean. optional. default: false. true: hide identities of voters." } }
      tr { td { plain "discussion_id" }; td { plain "integer. optional. default: null. id of discussion thread to add this poll to." } }
      tr { td { plain "recipient_audience" }; td { plain "string 'group' or null. optional. default: null. if 'group' whole group will be notified about the new thread." } }
      tr { td { plain "notify_on_closing_soon" }; td { plain "string. optional. default: 'nobody'. values: 'nobody', 'author', 'undecided_voters' or 'voters'. specify the who to send a reminder notification to, 24 hours before the poll closes." } }
      tr { td { plain "recipient_user_ids" }; td { plain "array of user ids to notify or invite" } }
      tr { td { plain "recipient_emails" }; td { plain "array of email addresses of people to invite to vote" } }
      tr { td { plain "recipient_message" }; td { plain "message to include in the email invitation" } }
      tr { td { plain "notify_recipients" }; td { plain "boolean. default false. false: add people to a poll without sending notifications. true: everyone invited (in this request) will get a notification email." } }
    end
  end
end
