When(/^I convert "(.*?)"$/) do |iana_string|
  @city = TimeZoneToCity.convert(iana_string)
end

Then(/^the city is "(.*?)"$/) do |city|
  city.should == @city
end
