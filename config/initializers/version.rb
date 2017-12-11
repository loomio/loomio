PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version
    def group
      item.group
    end
  end
end
