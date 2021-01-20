require 'rails_helper'

describe 'Object.retry_with_limit' do
  it 'retrys a limited number of times if there is an exception' do
    count = 0
    expect do
      RetryOnError.with_limit(5) do
        count += 1
        raise "this is an error"
      end
    end.to raise_error "this is an error"
    expect(count).to eq 5
  end

  it 'runs once if no error' do
    count = 0
    expect do
      RetryOnError.with_limit(5) do
        count += 1
      end
    end.not_to raise_error
    expect(count).to eq 1
  end
end
