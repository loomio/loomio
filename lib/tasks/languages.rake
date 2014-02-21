# zeus rake languages:update

namespace :languages do
  task :update => :environment do
    @options = { basic_auth: {username: ENV['TRANSIFEX_USERNAME'], password: ENV['TRANSIFEX_PASSWORD']} }

    language_info = HTTParty.get('http://www.transifex.com/api/2/project/loomio-1/languages', @options)

    languages_hash = {}
    language_info.each do |l|
      lang_code = l['language_code']
      language = lang_code.split('_')[0]
      if languages_hash[language].nil?
        languages_hash[language] = [lang_code]
      else
        languages_hash[language] += [lang_code]
      end
    end
    p "current languages:"
    p languages_hash

    def update(lang_code)
      response = HTTParty.get("http://www.transifex.com/api/2/project/loomio-1/resource/github-linked-version/translation/#{lang_code}", @options)

      if response.present?
        content = response['content']

        simplified_language = lang_code.split('_')[0]
        content = content.gsub(lang_code, simplified_language)

        target = File.open("config/locales/#{simplified_language}.yml", 'w')
        target.write(content)
        target.close()

        puts "#{simplified_language} processed"
      end
    end

    languages_hash.each_pair do |language, lang_code_array|
      if language == 'pt'
        update('pt_BR')
      elsif language == 'ga'
        update('ga_IE')
      elsif lang_code_array.length > 1
        raise "there are multiple dialects for this language and we currently don't support this!"
      else
        update(lang_code_array.first)
      end
    end

    puts "Remember to check EXPERIMENTAL_LANGUAGES array ^_^"
  end
end