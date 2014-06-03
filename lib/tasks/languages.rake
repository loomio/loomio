# zeus rake languages:update

namespace :languages do
  LOGIN = { basic_auth: {username: ENV['TRANSIFEX_USERNAME'], password: ENV['TRANSIFEX_PASSWORD']} }
  DIALECT_OVERRIDES = { 'pt' => 'pt_BR',
                        'ga' => 'ga_IE',
                        'sr' => 'sr' }
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

      printf '%20s', "\e[32m #{dialect}\e[0m : "

      RESOURCES.keys.each do |resource|
        update(dialect, resource)
      end

      print "\n"
    end

    puts "Remember to check EXPERIMENTAL_LANGUAGES array ^_^"
  end
end


#this method returns all key-chains which have variables in them.
def dig_hash(input_hash, key_trace = '')
  input_hash.keys.each do |key|
    extended_key_trace = key_trace + key + '.'

    one_in = input_hash[key]
    if one_in.is_a?(String)
      if one_in.scan(/%{[^%{}]*}/).present?
        puts "#{extended_key_trace.chomp('.')} = #{one_in}"
      end
      # check if there are any : .scan(/%{[^%{}]*}/).present?

    else
      dig_hash(one_in, extended_key_trace)
    end
  end
end
