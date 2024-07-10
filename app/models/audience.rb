class Audience
  private_class_method :new # use Audience.[collection_name] to initialize

  attr_reader :name

  AUDIENCES = %w[group discussion].freeze

  def initialize(audience_type)
    @name = audience_type
  end

  AUDIENCES.each do |audience|
    define_singleton_method(audience) do
      new(audience).name
    end
  end

  def self.all
    AUDIENCES
  end
end
