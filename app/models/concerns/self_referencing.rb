module SelfReferencing
  extend ActiveSupport::Concern

  included do |base|
    define_method base.name.downcase,          -> { self }
    define_method :"#{base.name.downcase}_id", -> { self.id }
  end
end
