module Plugins
  module ModuleConstMissing
    def const_missing(const_name)
      super.tap do |const|
        if Plugins::Repository.reload_callbacks.has_key?(const.name)
          Plugins::Repository.reload_callbacks[const.name].map { |proc| proc.call(const) }
        end
      end
    end
  end
end
