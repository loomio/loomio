module Null::Object
  def apply_null_methods!
    apply_null_method :nil_methods,   nil
    apply_null_method :false_methods, false
    apply_null_method :empty_methods, []
    apply_null_method :hash_methods,  {}
    apply_null_method :true_methods,  true
    apply_null_method :zero_methods,  0
    apply_null_method :none_methods,  ->(model) { model.to_s.singularize.classify.constantize.none }
  end

  def apply_null_method(name, value)
    send(name).each do |method, model|
      self.class.send :define_method, method, ->(*args) {
        value.respond_to?(:call) ? value.call(model) : value
      }
    end
  end

  def nil_methods
    []
  end

  def false_methods
    []
  end

  def empty_methods
    []
  end

  def hash_methods
    []
  end

  def true_methods
    []
  end

  def zero_methods
    []
  end

  def none_methods
    []
  end
end
