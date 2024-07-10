class Audience
  private_class_method :new # use Audience.[collection_name] to initialize

  attr_reader :name

  AUDIENCES = %w[group discussion].freeze

  def initialize(audience_type)
    @name = audience_type
  end

  def translate
    I18n.t(:"user.audience.#{name}", default: name )
  end

  AUDIENCES.each do |audience|
    define_singleton_method(audience) do
      new(audience)
    end
  end

  def self.dictionary
    AUDIENCES.each_with_object({}) { |audience, hash| hash[send(audience).translate] = audience }
  end

  def self.all_translated
    dictionary.keys
  end

  def self.back_translate(word)
    dictionary[word]
  end
end
