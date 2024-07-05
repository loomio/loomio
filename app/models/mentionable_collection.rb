class MentionableCollection
  private_class_method :new # use MentionableCollection.[collection_name] to initialize

  attr_reader :name, :collection

  COLLECTIONS = %w[group thread].freeze
  @@instance = {}

  def initialize(collection)
    @name = collection

    initialize_collection
  end

  def translate
    I18n.t(:"user.mentionable_collection.#{name}", default: nil )
  end

  COLLECTIONS.each do |collection|
    define_singleton_method(collection) do
      @@instance[collection] ||= new(collection)
    end
  end

  def initialize_collection
    return if @collection

    translated_name = translate
    existing_collections = User.where('users.name = :translated_name AND users.collection = false OR
                                        users.name <> :translated_name AND users.email = :email',
                                        translated_name:,
                                        email: "#{name}@loomio")

    existing_collections.each do |user|
      if user.email == "#{name}@loomio"
        user.destroy! # Prevents collection creation error on locale changes
        next
      end

      random_num = SecureRandom.random_number(9000) + 1000
      user.name = "#{user.name}#{random_num}" if user.name == translated_name
      user.username = "#{user.username}#{random_num}" if user.username == translated_name

      user.save!
    end

    @collection = User.find_by(name: translated_name) ||
                  User.create!(email: "#{name}@loomio",
                              name: translated_name,
                              password: SecureRandom.hex(20),
                              email_verified: true,
                              collection: true,
                              avatar_kind: :gravatar)
  end

  def self.encased_all
    COLLECTIONS.map{ |c| send(c) }.freeze
  end

  def self.all
    COLLECTIONS.map{ |c| send(c).collection }.freeze
  end

  def self.pluck(*args)
    all.pluck(*args)
  end
end
