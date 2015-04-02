require 'rest-client'

module Clients
  Base = Struct.new(:event) do

    def ready?
      post_uri.present? && payload.present?
    end

    def post!
      return false unless ready?
      RestClient.post post_uri, payload, headers
    end

    private

    def post_uri
      raise NotImplementedError.new
    end

    def payload
      raise NotImplementedError.new
    end

    def headers
      {}
    end
  end
end