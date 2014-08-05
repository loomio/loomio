# zeus rake languages:update

namespace :languages do
  LOGIN = { basic_auth: {username: ENV['TRANSIFEX_USERNAME'], password: ENV['TRANSIFEX_PASSWORD']} }

  RESOURCES = { 'github-linked-version' => 'en.yml',
                'frontpageenyml'        => 'frontpage.en.yml' }

  THRESHOLDS = { "Live" => 80 }

  task :update => :environment do
    language_info = HTTParty.get('http://www.transifex.com/api/2/project/loomio-1/languages', LOGIN)
    locales = locale_array(language_info)
    fixed_locales = locales.map {|l| l.gsub('_','-')}

    puts "\n TRANSIFEX LOCALES = " + fixed_locales.join(' ') +"\n\n"
    puts " UPDATING \n"

    # note we're only fetching stats on the Main resource
    language_stats = HTTParty.get('http://www.transifex.com/api/2/project/loomio-1/resource/github-linked-version/stats', LOGIN)


    locales.each do |locale|
      print_status(locale, language_stats)

      RESOURCES.keys.each do |resource|
        update(locale, resource)
      end
      print "\n"
    end


    Rake::Task["languages:check_interpolations"].invoke(fixed_locales)

    Rake::Task["languages:check_exp_locales"].invoke(fixed_locales)


    print "\n\n"
    puts " DONE!! ^_^"
    print "\n"
  end

  task :check_interpolations, [:locales] => [:environment] do |t, args|
    args.with_defaults(:locales => LocalesHelper::LOCALE_STRINGS + LocalesHelper::EXPERIMENTAL_LOCALE_STRINGS)


    print "\n"

    RESOURCES.values.each do |file|
      print " CHECKING INTERPOLATION AGAINST #{cyan(file)} \n\n  "

      source_language_hash = YAML.load(File.read("config/locales/#{file}"))
      keys_with_variables = find_keys_with_variables(source_language_hash).map {|key| key[2..-2] }

      args[:locales].each do |locale|
        print "#{grey(locale)} "
        keys_with_variables.each do |key|
          english_str = I18n.t(key, locale: :en)
          foreign_str = I18n.t(key, locale: locale)
          english_variables = parse_for_variables english_str
          foreign_variables = parse_for_variables foreign_str

          if english_variables.any? { |var| !foreign_variables.include?(var) }
            bolded_english = english_str.gsub('%{', "\e[1m%{").gsub('}', "}\e[22m")

            print "    #{locale.to_s}#{key}\n"
            print "\t\e[32m#{bolded_english}\e[0m\n"
            print "\t#{foreign_str}\n\n"
            print "\t\e[30mhttps://www.transifex.com/projects/p/loomio-1/translate/##{locale.to_s}/#{RESOURCES.key(file)}/?key=#{key[1..-1]}\e[0m\n\n"
          end
        end
      end
      print "\n\n"
    end

    print "\n"
  end

  task :check_exp_locales, [:locales] => [:environment] do |t, args|
    print "\n EXPERIMENTAL_LOCALE_STRINGS = %w( "
    pretty_l = (args[:locales] - LocalesHelper::LOCALE_STRINGS).map do |l|
      if LocalesHelper::EXPERIMENTAL_LOCALE_STRINGS.include? l
        grey(l)
      else
        bold(green(l))
      end
    end.join(' ') + ' )'
    puts pretty_l
    print "\n"
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

def update(locale, resource)
  fixed_locale = locale.gsub('_', '-')
  filename = RESOURCES[resource].chomp('en.yml') + "#{fixed_locale}.yml"

  response = HTTParty.get("http://www.transifex.com/api/2/project/loomio-1/resource/#{resource}/translation/#{locale}", LOGIN)

  if response.present? && content = response['content']
    target = File.open("config/locales/#{filename}", 'w')
    target.write(content.gsub(locale, fixed_locale))
    target.close()

    printf "%18s ", grey(filename)
  else
    puts "ERROR!! -- #{locale} - #{filename}"
  end
end

def print_status(locale, language_stats)
  fixed_locale_str = locale.to_s.gsub('_','-')
  fixed_locale     = fixed_locale_str.to_sym
  perc_comp_str = percent_complete(locale, language_stats)
  perc_comp     = perc_comp_str.to_i

  fixed_locale_str = cyan(fixed_locale_str)

  if LocalesHelper::LANGUAGES.values.include? fixed_locale
    if perc_comp >= THRESHOLDS["Live"] - 5
      state         = bold('Live')
      perc_comp_str = grey(perc_comp_str)
    else
      state         = 'Live'
      perc_comp_str = red(perc_comp_str)
    end

  else
    if perc_comp >= THRESHOLDS["Live"] - 10
      fixed_locale_str = bold(fixed_locale_str)
      state            = green(" ^  ")
      perc_comp_str    = green(perc_comp_str)
    else
      state            = grey(" -  ")
      perc_comp_str    = grey(perc_comp_str)
    end
  end

  printf "\t%s %s %s", pad_string_to(fixed_locale_str, 8), pad_string_to(state, 8), pad_string_to(perc_comp_str, 15)
end


def percent_complete(locale, language_stats)
  language_stats.with_indifferent_access[locale]["completed"]
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

def bold(string)
  "\e[1m#{string}\e[22m"
end

def locale_array(language_info)
  language_info.map {|l| l['language_code'] }
end

def pad_string_to(string, desired_length)
  printed_length = string.gsub(/\e[\[0-9]+m/,'').length

  (desired_length - printed_length).times { string += ' ' }
  string
end

