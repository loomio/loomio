# zeus rake languages:update

namespace :languages do
  LOGIN = { basic_auth: {username: ENV['TRANSIFEX_USERNAME'], password: ENV['TRANSIFEX_PASSWORD']} }
  DIALECT_OVERRIDES = { 'pt' => 'pt_BR',
                        'ga' => 'ga_IE',
                        'sr' => 'sr',
                        'es' => 'es' }

  RESOURCES = { 'github-linked-version' => 'en.yml' ,
                 'frontpageenyml' => 'frontpage.en.yml' }

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

    print "\n"
    Rake::Task["languages:check_variables"].invoke
    print "\n"
    print "\n"
    puts "Remember to check EXPERIMENTAL_LANGUAGES array ^_^"
  end

  task :check_variables => :environment do
    RESOURCES.values.each do |file|
      print "CHECKING KEYS AGAINST #{file} \n\n"

      source_language_hash = YAML.load(File.read("config/locales/#{file}"))
      keys_with_variables = find_keys_with_variables(source_language_hash).map {|key| key[2..-2] }

      AppTranslation::LANGUAGES.values.each do |language|
        keys_with_variables.each do |key|
          english_str = I18n.t(key, locale: :en)
          foreign_str = I18n.t(key, locale: language)
          english_variables = parse_for_variables english_str
          foreign_variables = parse_for_variables foreign_str

          if english_variables.any? { |var| !foreign_variables.include?(var) }
            bolded_english = english_str.gsub('%{', "\e[1m%{").gsub('}', "}\e[22m")

            print "  #{language.to_s}#{key}\n"
            print "\t\e[32m#{bolded_english}\e[0m\n"
            print "\t#{foreign_str}\n\n"
          end
        end
      end

    end

  end
end


#this method returns all key-chains which have variables in them.
def find_keys_with_variables(input_hash, key_trace = '')
  target_keys = []

  input_hash.keys.each do |key|
    extended_key_trace = key_trace + key + '.'

    hash_or_string = input_hash[key]
    if hash_or_string.is_a? Hash
      result_from_deeper = find_keys_with_variables(hash_or_string, extended_key_trace)
      target_keys << result_from_deeper unless result_from_deeper.empty?
    else
      target_keys << extended_key_trace if contains_variables?(hash_or_string)
    end
  end

  target_keys.flatten
end

def parse_for_variables(str)
  str.scan(/%{[^%{}]*}/)
end

def contains_variables?(str)
  parse_for_variables(str).present?
end

##############

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
