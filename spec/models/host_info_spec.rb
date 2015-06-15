require 'rails_helper'

describe HostInfo do
  let(:host_info) { HostInfo.new(request) }
  let(:request){ double(
    port: 3000,
    ssl?: true,
    host: 'localhost',
    domain: nil
  ) }
  let(:request_with_domain) { double(
    post: 3000,
    ssl?: true,
    host: 'www.loomio.org',
    domain: 'loomio.org'
  )}

  it 'prefers domain over host for host' do
    expect(HostInfo.new(request_with_domain).host).to eq request_with_domain.domain
  end

  it 'pulls attributes from the request' do
    expect(host_info.port).to eq request.port
    expect(host_info.host).to eq request.host
    expect(host_info.ssl).to eq request.ssl?
  end

  it 'pulls default subdomain from ENV' do
    temp, ENV["DEFAULT_SUBDOMAIN"] = ENV["DEFAULT_SUBDOMAIN"], "wark"
    expect(host_info.default_subdomain).to eq "wark"
    ENV["DEFAULT_SUBDOMAIN"] = temp
  end

  it 'responds to read_attribute_for_serialization' do
    expect(host_info.read_attribute_for_serialization(:port)).to eq request.port
  end
end
