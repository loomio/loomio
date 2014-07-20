# zeus rake languages:update

namespace :languages do
  LOGIN = { basic_auth: {username: ENV['TRANSIFEX_USERNAME'], password: ENV['TRANSIFEX_PASSWORD']} }
  DIALECT_OVERRIDES = { 'pt' => 'pt_BR',
                        'ga' => 'ga_IE',
                        'sr' => 'sr',
                        'es' => 'es' }

  RESOURCES = { 'github-linked-version' => 'en.yml' ,
                 'frontpageenyml' => 'frontpage.en.yml' }

  THRESHOLDS = { "Live" => 80,
                 "Exp"  => 40 }

  task :update => :environment do
    language_info = HTTParty.get('http://www.transifex.com/api/2/project/loomio-1/languages', LOGIN)
    languages_hash = build_languages_hash(language_info)

    # note we're only fetching stats on the Main resource
    language_stats = HTTParty.get('http://www.transifex.com/api/2/project/loomio-1/resource/github-linked-version/stats', LOGIN)

    puts "current languages = #{languages_hash.keys}"
    check_all_languages_for_competition(languages_hash)

    languages_hash.keys.each do |language|
      dialect = decide_dialect(language, languages_hash)

      printf '%20s %16s', cyan(dialect), status(dialect, language_stats)

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
            print "\t\e[30mhttps://www.transifex.com/projects/p/loomio-1/translate/##{language.to_s}/#{RESOURCES.key(file)}/?key=#{key[1..-1]}\e[0m\n\n"
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

    printf "%18s ", grey(filename)
  else
    puts "ERROR!! -- #{simplified_language} - #{filename}"
  end
end

def status(lang_code, language_stats)
  simplified_language = lang_code.split('_')[0].to_sym
  perc_comp_str = percent_complete(lang_code, language_stats)
  perc_comp = perc_comp_str.to_i
    perc_comp_str += " " unless perc_comp == 100
    perc_comp_str += " " if perc_comp < 10

  if AppTranslation.locales.include? simplified_language
    if perc_comp >= THRESHOLDS["Live"] - 5
      "\e[1mLive\e[22m #{perc_comp_str}"
    else
      red("Live #{perc_comp_str}")
    end

  elsif AppTranslation.experimental_locales.include? simplified_language
    if perc_comp >= THRESHOLDS["Live"] - 5
      green("Exp  #{perc_comp_str}")
    else
     "\e[0mExp  #{perc_comp_str}\e[0m"
    end

  else
    if perc_comp >= THRESHOLDS["Exp"] - 5
      green(" ^   #{perc_comp_str}")
    else
       grey(" -   #{perc_comp_str}")
    end
  end
end

def percent_complete(lang_code, language_stats)
  language_stats[lang_code]["completed"]
end

def green(string)
  "\e[92m#{string}\e[0m"
end

def red(string)
  "\e[91m#{string}\e[0m"
end

def grey(string)
  "\e[30m#{string}\e[0m"
end

def cyan(string)
  "\e[96m#{string}\e[0m"
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
