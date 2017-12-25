PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version
    def created_event
      item.created_event
    end

    def parent_event
      item.parent_event
    end
  end
end
