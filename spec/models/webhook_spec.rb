require 'rails_helper'

describe Webhook do
  it { should validate_presence_of :uri }
  it { should respond_to(:headers) } # we don't use headers yet; maybe for other services

  it 'should have a valid factory :)' do
    expect(build(:webhook)).to be_valid
  end

  it 'should validate presence of hookable' do
    expect(build(:webhook, hookable: nil)).to_not be_valid
  end

  it 'should validate event_types not being empty' do
    expect(build(:webhook, event_types: [])).to_not be_valid
  end

  it 'should validate the webhook kind' do
    expect(build(:webhook, kind: 'notakind')).to_not be_valid
  end
end
