ActiveSupport.on_load(:active_record) do
  include IsTranslatable::Model
end
