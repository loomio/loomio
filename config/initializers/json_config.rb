# Suppress duplicate key warnings from JSON serialization
# These come from active_model_serializers v0.8.1 which emits both symbol and string keys
# The warnings are harmless and don't affect functionality

if Warning.respond_to?(:ignore)
  Warning.ignore(/duplicate key/)
else
  # Fallback for older Ruby versions
  original_warn = Warning.method(:warn)
  Warning.define_singleton_method(:warn) do |message|
    # Suppress duplicate key warnings but show other warnings
    original_warn.call(message) unless message.to_s.include?('duplicate key')
  end
end
