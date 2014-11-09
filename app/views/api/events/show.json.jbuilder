json.event do
  json.partial! 'api/discussions/item', item: @event
end
