require 'rails_helper'

describe TimeZoneToCity do
  it 'Convert common IANA timezone to city name' do
    expect(TimeZoneToCity.convert("Pacific/Auckland")).to eq "Auckland"
  end

  it 'Convert obscure IANA timezone to city name' do
    expect(TimeZoneToCity.convert("Pacific/Tarawa")).to eq "Wellington"
  end
end
