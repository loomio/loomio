module Clients
  class Slack < Base
    def post_uri
      ENV['SLACK_WEBHOOK']
    end

    def payload
      
    end
  end
end