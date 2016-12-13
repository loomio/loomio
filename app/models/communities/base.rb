class Communities::Base < ActiveRecord::Base
  self.table_name = :communities
  validates :community_type, presence: true

  def self.set_community_type(type)
    after_initialize { self.community_type = type }
  end

  def self.set_custom_fields(*fields)
    fields.each do |field|
      define_method field,        ->        { self[:custom_fields][field] }
      define_method :"#{field}=", ->(value) { self[:custom_fields][field] = value }
    end
  end

  # ensure that we're instantiating the correct community type for each community fetched
  # fallback to a Communities::Base if we can't find an appropriate subclass
  # (note that Communities::Base will error when sent the 'includes?' or 'participants' message)
  def self.discriminate_class_for_record(attributes)
    "Communities::#{attributes.fetch('community_type', 'base').classify}".constantize
  rescue NameError
    self
  end

  def custom_fields=(value)
    warn "Setting custom fields directly is not recommended. Please use the getters and setters provided by the 'set_custom_fields' method instead."
    super
  end

  def custom_fields
    warn "Accessing custom fields directly is not recommended. Please use the getters and setters provided by the 'set_custom_fields' method instead."
    super
  end

  def includes?(participant)
    raise NotImplementedError.new
  end

  def participants
    raise NotImplementedError.new
  end

end
