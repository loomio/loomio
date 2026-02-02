require 'net/http'
require 'json'

module TranslationProviders
  class Deepl < Base
    SUPPORTED_LOCALES = %w[ar bg cs da de el en es et fi fr hu id it ja ko lt lv nb nl pl pt ro ru sk sl sv tr uk zh]

    def self.available?
      ENV['DEEPL_API_KEY'].present?
    end

    def translate(content, to:, format: :text)
      uri = build_uri
      request = build_request(uri, content, to, format)
      response = execute_request(uri, request)
      parse_response(response)
    end

    def supported_languages
      SUPPORTED_LOCALES
    end

    def normalize_locale(locale)
      locale = locale.to_s.downcase.gsub("_", "-")
      base_locale = locale.split("-")[0]
      return base_locale if SUPPORTED_LOCALES.include?(base_locale)
      base_locale
    end

    private

    def endpoint
      if ENV['DEEPL_API_KEY']&.end_with?(':fx')
        'https://api-free.deepl.com/v2/translate'
      else
        'https://api.deepl.com/v2/translate'
      end
    end

    def build_uri
      URI(endpoint)
    end

    def build_request(uri, content, to, format)
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "DeepL-Auth-Key #{ENV['DEEPL_API_KEY']}"
      request['Content-Type'] = 'application/x-www-form-urlencoded'

      params = {
        'text' => content,
        'target_lang' => to.upcase
      }
      params['tag_handling'] = 'html' if format == :html

      request.body = URI.encode_www_form(params)
      request
    end

    def execute_request(uri, request)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def parse_response(response)
      JSON.parse(response.body)['translations'][0]['text']
    end
  end
end
