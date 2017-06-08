module HasCustomFields
  def set_custom_fields(*fields)
    fields.map(&:to_s).each do |field|
      define_method field,        ->        { self[:custom_fields][field] }
      define_method :"#{field}=", ->(value) { self[:custom_fields][field] = value }
    end
  end
end
