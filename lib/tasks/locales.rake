# zeus rake locales:update

namespace :locales do
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


    Rake::Task["locales:check"].invoke

    print "\n\n"
    puts " DONE!! ^_^"
    print "\n"
  end

  task :check => :environment do
    #could be drier
    language_info = HTTParty.get('http://www.transifex.com/api/2/project/loomio-1/languages', LOGIN)
    locales = locale_array(language_info)
    fixed_locales = locales.map {|l| l.gsub('_','-')}

    Rake::Task["locales:check_codelike_text"].invoke(fixed_locales)
    Rake::Task["locales:check_exp_locales"].invoke(fixed_locales)
  end

  task :check_codelike_text, [:locales] => [:environment] do |t, args|
    args.with_defaults(:locales => Loomio::I18n::SELECTABLE_LOCALES + Loomio::I18n::TEST_LOCALES )

    print "\n"

    RESOURCES.values.each do |file|
      print " CHECKING CODE-LIKE TEXT AGAINST #{cyan(file)} \n\n  "

      source_language_hash = YAML.load(File.read("config/locales/#{file}"))

      keys_to_ignore = [ '.invitation.invitees_placeholder' ]

      keys_with_variables = find_keys_with_variables(source_language_hash).map {|key| key[2..-2] }
      keys_with_html = find_keys_with_html(source_language_hash).map {|key| key[2..-2] } - keys_to_ignore

      args[:locales].each do |locale|
        print "#{grey(locale)} "
        transifex_locale = (locale.to_s).gsub('-','_')

        keys_with_variables.each do |key|
          english_str = I18n.t(key, locale: :en)
          foreign_str = I18n.t(key, locale: locale)
          english_variables = parse_for_variables english_str
          foreign_variables = parse_for_variables foreign_str

          if english_variables.any? { |var| !foreign_variables.include?(var) }
            bolded_english = english_str.gsub('%{', "\e[1m%{").gsub('}', "}\e[22m")

            print "\n    #{locale.to_s}#{key}\n"
            print "\t\e[32m#{bolded_english}\e[0m\n"
            print "\t#{foreign_str}\n\n"
            print "\t\e[30mhttps://www.transifex.com/projects/p/loomio-1/translate/##{transifex_locale}/#{RESOURCES.key(file)}/?key=#{key[1..-1]}\e[0m\n\n"
          end
        end

        keys_with_html.each do |key|
          english_str = I18n.t(key, locale: :en)
          foreign_str = I18n.t(key, locale: locale)
          english_html = parse_for_html english_str
          foreign_html = parse_for_html foreign_str

          if english_html.any? { |var| !foreign_html.include?(var) }
            bolded_english = english_str.gsub('<', "\e[1m<").gsub('>', ">\e[22m")

            print "\n    #{locale.to_s}#{key}\n"
            print "\t\e[32m#{bolded_english}\e[0m\n"
            print "\t#{foreign_str}\n\n"
            print "\t\e[30mhttps://www.transifex.com/projects/p/loomio-1/translate/##{transifex_locale}/#{RESOURCES.key(file)}/?key=#{key[1..-1]}\e[0m\n\n"
          end
        end
      end
      print "\n\n"
    end

    print "\n"
  end

  task :check_exp_locales, [:locales] => [:environment] do |t, args|
    # args.with_defaults(:locales => LocalesHelper::LOCALE_STRINGS + LocalesHelper::TEST_LOCALES)

    print "\n TEST_LOCALES = %i( "
    pretty_l = (args[:locales].map(&:to_sym) - Loomio::I18n::SELECTABLE_LOCALES).map do |l|
      if Loomio::I18n::TEST_LOCALES.include? l
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

# this method returns all key-chains which have html tags in them
def find_keys_with_html(input_hash, key_trace = '')
  target_keys = []

  input_hash.keys.each do |key|
    extended_key_trace = key_trace + key + '.'

    hash_or_string = input_hash[key]
    if hash_or_string.is_a? Hash
      result_from_deeper = find_keys_with_html(hash_or_string, extended_key_trace)
      target_keys << result_from_deeper unless result_from_deeper.empty?
    else
      target_keys << extended_key_trace if contains_html?(hash_or_string)
    end
  end

  target_keys.flatten
end

def parse_for_html(str)
  str.scan(/\<[^\<\>]+\>/)
end

def contains_html?(str)
  parse_for_html(str).present?
end
##############

def update(locale, resource)
  fixed_locale = locale.gsub('_', '-')
  filename = RESOURCES[resource].chomp('en.yml') + "#{fixed_locale}.yml"

  response = HTTParty.get("http://www.transifex.com/api/2/project/loomio-1/resource/#{resource}/translation/#{locale}", LOGIN)

  if response.present? && content = response['content']
    content = content.gsub(/^#{locale}:/, "#{fixed_locale}:")

    if should_update? filename, content
      target = File.open("config/locales/#{filename}", 'w')
      target.write(content)
      target.close()
      printf "%18s ", green(filename)
    else
      printf "%18s ", grey(filename)
    end
  else
    puts "ERROR!! -- #{locale} - #{filename}"
  end
end

def should_update?(filename, content)
  return true if !File.exist?("config/locales/#{filename}")

  current_hash = YAML.load(File.read("config/locales/#{filename}"))
  new_hash = YAML.load(content)

  current_hash != new_hash
end

def print_status(locale, language_stats)
  fixed_locale_str = locale.to_s.gsub('_','-')
  fixed_locale     = fixed_locale_str.to_sym
  perc_comp_str = percent_complete(locale, language_stats)
  perc_comp     = perc_comp_str.to_i

  fixed_locale_str = cyan(fixed_locale_str)

  if Loomio::I18n::SELECTABLE_LOCALES.include? fixed_locale
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
  "\e[32m#{string}\e[0m"
end

def red(string)
  "\e[31m#{string}\e[0m"
end

def grey(string)
  "\e[30m#{string}\e[0m"
end

def cyan(string)
  "\e[36m#{string}\e[0m"
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
