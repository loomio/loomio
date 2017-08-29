PaperTrail::Version.class_eval do
  delegate :poll, to: :item, allow_nil: true
end
