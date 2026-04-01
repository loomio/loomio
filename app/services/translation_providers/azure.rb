require 'net/http'
require 'json'

module TranslationProviders
  class Azure < Base
    ENDPOINT = 'https://api.cognitive.microsofttranslator.com'
    SUPPORTED_LOCALES = %w[af am ar as az ba be bg bho bn bo brx bs ca cs cy da de doi dsb dv el en es et eu fa fi fil fj fo fr fr-ca ga gl gom gu ha he hi hne hr hsb ht hu hy id ig ikt is it iu iu-latn ja ka kk km kmr kn ko ks ku ky lb ln lo lt lug lv lzh mai mg mi mk ml mn-cyrl mn-mong mni mr ms mt mww my nb ne nl nso nya or otq pa pl prs ps pt pt-pt ro ru run rw sd si sk sl sm sn so sq sr-cyrl sr-latn st sv sw ta te th ti tk tlh-latn tlh-piqd tn to tr tt ty ug uk ur uz vi xh yo yua yue zh-hans zu]

    def self.available?
      ENV['AZURE_TRANSLATOR_KEY'].present?
    end

    def translate(content, to:, format: :text)
      uri = build_uri(to, format)
      request = build_request(uri, content)
      response = execute_request(uri, request)
      parse_response(response)
    end

    def supported_languages
      SUPPORTED_LOCALES
    end

    def normalize_locale(locale)
      locale = locale.to_s.downcase.gsub("_", "-")
      return locale if SUPPORTED_LOCALES.include?(locale)
      locale.split("-")[0]
    end

    private

    def build_uri(to, format)
      query = "api-version=3.0&to=#{to}"
      query += "&textType=html" if format == :html
      URI("#{ENDPOINT}/translate?#{query}")
    end

    def build_request(uri, content)
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TRANSLATOR_KEY']
      request['Ocp-Apim-Subscription-Region'] = ENV['AZURE_TRANSLATOR_REGION'] if ENV['AZURE_TRANSLATOR_REGION']
      request.body = [{ 'Text' => content }].to_json
      request
    end

    def execute_request(uri, request)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end
    end

    def parse_response(response)
      JSON.parse(response.body)[0]['translations'][0]['text']
    end
  end
end
