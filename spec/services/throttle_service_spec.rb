require 'rails_helper'

describe 'ThrottleService' do
  it 'limits the number of times i can do something' do
    CHANNELS_REDIS_POOL.with do |client|
      client.flushall
    end
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)).to be true
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)).to be true
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)).to be true
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)).to be true
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)).to be true
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)).to be false
  end

  it 'limits the number of times i can do something, with inc' do
    CHANNELS_REDIS_POOL.with do |client|
      client.flushall
    end
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)).to be true
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)).to be true
    expect(ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)).to be false
    expect(ThrottleService.can?(key: 'jump', id: 2, max: 5, per: 'hour', inc: 2)).to be true
    expect(ThrottleService.can?(key: 'jump', id: 2, max: 5, per: 'hour', inc: 2)).to be true
    expect(ThrottleService.can?(key: 'jump', id: 2, max: 5, per: 'hour', inc: 2)).to be false
  end

  it "raises exception for limit!" do
    CHANNELS_REDIS_POOL.with do |client|
      client.flushall
    end
    expect(ThrottleService.limit!(key: 'jump', max: 1, per: 'hour', inc: 1)).to be true
    expect { ThrottleService.limit!(key: 'jump', max: 1, per: 'hour', inc: 1) }.to raise_error
  end
end
