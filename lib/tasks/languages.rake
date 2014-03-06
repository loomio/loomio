# zeus rake languages:update

namespace :languages do
  LOGIN = { basic_auth: {username: ENV['TRANSIFEX_USERNAME'], password: ENV['TRANSIFEX_PASSWORD']} }
  DIALECT_OVERRIDES = { 'pt' => 'pt_BR',
                        'ga' => 'ga_IE' }
  RESOURCES = { 'github-linked-version' => 'en.yml' ,
                 'frontpageenyml' => 'frontpage.en.yml' }

  def build_languages_hash(language_info)
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
    languages_hash
  end

  def check_all_languages_for_competition(languages_hash)
    languages_hash.keys.each do |language|
      check_language_for_competition(language, languages_hash)
    end
  end

  def check_language_for_competition(language, languages_hash)
    if languages_hash[language].length > 1 && !DIALECT_OVERRIDES.keys.include?(language)
      raise "there are multiple unresolved dialects for #{language} and we currently don't support this!"
    end
  end

  def decide_dialect(language, languages_hash)
    check_language_for_competition(language, languages_hash)

    DIALECT_OVERRIDES[language] || languages_hash[language].first
  end

  def update(lang_code, resource)
    simplified_language = lang_code.split('_')[0]
    filename = RESOURCES[resource].chomp('en.yml') + "#{simplified_language}.yml"

    response = HTTParty.get("http://www.transifex.com/api/2/project/loomio-1/resource/#{resource}/translation/#{lang_code}", LOGIN)

    if response.present? && content = response['content']

      content = content.gsub("#{lang_code}:", "#{simplified_language}:")


      target = File.open("config/locales/#{filename}", 'w')
      target.write(content)
      target.close()

      print "#{filename} "
    else
      puts "ERROR!! -- #{simplified_language} - #{filename}"
    end
  end


  task :update => :environment do
    language_info = HTTParty.get('http://www.transifex.com/api/2/project/loomio-1/languages', LOGIN)
    languages_hash = build_languages_hash(language_info)

    check_all_languages_for_competition(languages_hash)
    puts "current languages = #{languages_hash.keys}"

    languages_hash.keys.each do |language|
      dialect = decide_dialect(language, languages_hash)

      print "[\e[31m #{dialect} \e[0m] : "

      RESOURCES.keys.each do |resource|
        update(dialect, resource)
      end

      print "\n"
    end

    puts "Remember to check EXPERIMENTAL_LANGUAGES array ^_^"
  end
end