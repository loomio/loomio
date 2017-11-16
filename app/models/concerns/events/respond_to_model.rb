# create a named getter method for each model type specified in MODEL_NAMES
# this is useful for polymorphic events (like announcement_created or reaction_created)
# which have polymorphic eventables, but may still wish to respond to messages like 'event.poll'
module Events::RespondToModel
  def self.included(base)
    %w(comment poll discussion formal_group).each do |model|
      base.send :define_method, model, -> { eventable.announceable if eventable.announceable_type == model.to_s.classify }
    end
  end
end
