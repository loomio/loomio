require_relative '../../lib/pluck_translations'


describe "Pluck translations" do
  let(:translations) {
    {
      'en' => {'a' => 'blue', 'b' => {'c' => 'red' }},
      'es' => {'a' => 'azul', 'b' => {'c' => 'rojo'}},
    }
  }

  before do
    #setup input_en.yml and input_es.yml as simple example
    translations.each_pair do |locale, pairs|
      File.open("input.#{locale}.yml", 'w') do |f|
        f.write({locale => pairs}.to_yaml)
      end
    end
  end

  after do
    translations.each_pair do |locale, pairs|
      File.delete("input.#{locale}.yml")
      File.delete("output.#{locale}.yml")
    end
  end


  it "copys a set of strings from one place to another" do
    LoomioI18n.pluck_translations(
      en_source_filename: 'input.en.yml',
      source_key: 'b',
      en_destination_filename: 'output.en.yml',
      destination_key: 'bb'
    )

    # read output_en.yml and confirm it has chips

    result = YAML.load_file('output.en.yml')
    expect(result['en']['bb']).to eq({'c' => 'red'})

    # read output_en.yml and confirm it has chips
    result = YAML.load_file('output.es.yml')
    expect(result['es']['bb']).to eq({'c' => 'rojo'})
  end

  it "copys a set of strings to a nested place" do
    LoomioI18n.pluck_translations(
      en_source_filename: 'input.en.yml',
      source_key: 'b',
      en_destination_filename: 'output.en.yml',
      destination_key: 'b.b'
    )

    # read output_en.yml and confirm it has chips

    result = YAML.load_file('output.en.yml')
    expect(result['en']['b']['b']).to eq({'c' => 'red'})

    # read output_en.yml and confirm it has chips
    result = YAML.load_file('output.es.yml')
    expect(result['es']['b']['b']).to eq({'c' => 'rojo'})
  end
end
