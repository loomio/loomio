class Clients::Slack < Clients::Base

  private

  def host
    "https://slack.com/api".freeze
  end
end
