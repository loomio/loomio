namespace :locales do
  task build: :environment do

    def single_curlify(hash)
      hash.each do |key, value|
        if value.is_a? String
          value.gsub!('{{', '{')
          value.gsub!('}}', '}')
        elsif value.is_a? Hash
          single_curlify(value)
        end
      end
    end

    AppConfig.locales['supported'].each do |locale|
      File.open("#{Rails.root}/vue/src/locales/#{locale}.json", "w") do |f|
        f.write single_curlify(Hash(YAML.load_file("config/locales/client.#{locale}.yml")[locale])).to_json
      end
    end
  end
end
