module LoomioI18n
  # next write spec that confirms some file is translated correctly.
  # boose:
  #   some_key: 'ok'
  # subject:
  #   thing: 'ues'

  # gives identical destination file
  # test inserts data
  # test does not destroy existing keys
  def self.pluck_translations(en_source_filename: ,
                             source_key:,
                             en_destination_filename:,
                             destination_key:)

    locales_with_filenames(en_source_filename,
                           en_destination_filename) do |locale, source_filename, destination_filename|


      subject = YAML.load_file(source_filename)[locale][source_key]
      next if subject.nil?

      destination = File.exists?(destination_filename) ? YAML.load_file(destination_filename) : {}

      path_in_hash("#{locale}.#{destination_key}", destination).merge!(subject)

      write_yaml_file(destination, destination_filename)

      delete_path_from_file("#{locale}.#{source_key}", source_filename)
    end
  end


  def self.write_yaml_file(obj, filename)
    File.open(filename, 'w') {|f| f.write YAML.dump(obj, {line_width: -1}) }
  end

  def self.delete_path_from_file(path, filename)
    # path should include locale
    # load source file. navigate to second last key, and delete last term.
    # then save the source file.
    keys = path.split('.')
    key = keys.pop

    data = YAML.load_file(filename)
    path_in_hash(keys.join('.'), data).delete(key)

    write_yaml_file(data, filename)
  end

  # give us the value at en.bar.foo
  # if foo does not exist, create a hash and return it
  def self.path_in_hash(path, hash)
    path.split('.').inject(hash) do |location, key|
      if location.has_key?(key)
        location[key]
      else
        location[key] = {}
      end
    end
  end

  def self.locales_with_filenames(en_source_filename, en_destination_filename)
    Dir[en_source_filename.gsub('en', "{#{locales.join(',')}}")].each do |filename|
      locale = /#{en_source_filename.gsub('en', '(.+)')}/.match(filename)[1]
      yield(locale,
            en_source_filename.gsub('en', locale),
            en_destination_filename.gsub('en', locale))
    end
  end

  def self.locales
    %w[af ar az be bg bn bs ca cs cy da de de-AT de-CH el en en-AU en-CA en-GB en-IE en-IN en-NZ en-US en-ZA eo es es-419 es-AR es-CL es-CO es-CR es-EC es-MX es-PA es-PE es-US es-VE et eu fa fi fr fr-CA fr-CH gl he hi hi-IN hr hu id is it it-CH ja km kn ko lb lo lt lv mk mn mr-IN ms nb ne nl nn or pa pl pt pt-BR rm ro ru sk sl sr sv sw ta th tl tr tt ug uk ur uz vi wo zh-CN zh-HK zh-TW zh-YUE]
  end
end
