Feature: Convert IANA timezone to city name
  In order to match obscure IANA timezones to cities on the Rails timezone select list
  I want to convert an IANA timezone string to a known city

  Scenario: Convert common IANA timezone to city name
    When I convert "Pacific/Auckland"
    Then the city is "Auckland"

  Scenario: Convert obscure IANA timezone to city name
    When I convert "Pacific/Tarawa"
    Then the city is "Wellington"
