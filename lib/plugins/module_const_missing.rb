module Plugins
  module ModuleConstMissing
    def const_missing(const_name)
      super.tap do |const|
        callbacks = Plugins::Repository.reload_callbacks
        callbacks[const_name].map { |proc| proc.call(const) } if callbacks.has_key?(const_name)
      end
    end
  end
end
