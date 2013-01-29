ValidatesTimeliness.setup do |config|
  # Extend ORM/ODMs for full support (:active_record, :mongoid).
  # config.extend_orms = [ :active_record ]
  #
  # Default timezone
  # config.default_timezone = :utc
  #
  # Set the dummy date part for a time type values.
  # config.dummy_date_for_time_type = [ 2000, 1, 1 ]
  #
  # Ignore errors when restriction options are evaluated
  # config.ignore_restriction_errors = false
  #
  # Re-display invalid values in date/time selects
  # config.enable_date_time_select_extension!
  #
  # Handle multiparameter date/time values strictly
  # config.enable_multiparameter_extension!
  #
  # Shorthand date and time symbols for restrictions
  # config.restriction_shorthand_symbols.update(
  #   :now   => lambda { Time.current },
  #   :today => lambda { Date.current }
  # )
  #
  # Use the plugin date/time parser which is stricter and extendable
  # config.use_plugin_parser = false
  #
  # Add one or more formats making them valid. e.g. add_formats(:date, 'd(st|rd|th) of mmm, yyyy')
  # config.parser.add_formats()
  #
  # Remove one or more formats making them invalid. e.g. remove_formats(:date, 'dd/mm/yyy')
  # config.parser.remove_formats()
  #
  # Change the amiguous year threshold when parsing a 2 digit year
  # config.parser.ambiguous_year_threshold =  30
  #
  # Treat ambiguous dates, such as 01/02/1950, as a Non-US date.
  # config.parser.remove_us_formats
end
