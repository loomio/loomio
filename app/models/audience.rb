class Audience
  private_class_method :new # use Audience.[name] to initialize

  attr_reader :name

  AUDIENCES = %w[group discussion].freeze

  def initialize(audience_type)
    @name = audience_type
  end

  AUDIENCES.each do |audience|
    define_singleton_method(audience) do
      new(audience)
    end
  end

  def alias
    {
      discussion: 'discussion_group'
    }[name.to_sym] || name
  end

  def translate
    I18n.t!("mentioning.#{name}")
  end

  def self.back_translate(word)
    return '' unless word.present?

    AUDIENCES.find { |audience| Audience.send(audience).translate == word }
  end

  def self.all(translate: false)
    if translate
      return AUDIENCES.map { |audience| send(audience).translate }
    end

    AUDIENCES
  end
end
