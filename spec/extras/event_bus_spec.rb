require 'rails_helper'

describe EventBus do

  let(:subject) { EventBus }
  let(:my_proc) { Proc.new { self.inspect } }
  let(:my_param_proc) { Proc.new { |param| param.is_a? my_param } }
  let(:my_param) { Object }

  before { @listeners = subject.class_variable_get(:@@listeners); subject.clear }
  after { subject.class_variable_set(:@@listeners, @listeners) }

  describe 'listen' do
    it 'activates a listener with an event name' do
      expect(self).to receive(:inspect)
      subject.listen('my_event', &my_proc)
      subject.broadcast('my_event')
    end

    it 'activates a listener with params' do
      expect(self).to receive(:is_a?).with(my_param)
      subject.listen('my_event', &my_param_proc)
      subject.broadcast('my_event', self)
    end

    it 'does not activate events with a different event name' do
      expect(self).to_not receive(:inspect)
      subject.listen('my_event', &my_proc)
      subject.broadcast('my_other_event')
    end

    it 'can accept multiple event names' do
      expect(self).to receive(:inspect).twice
      subject.listen('my_event', 'my_other_event', &my_proc)
      subject.broadcast('my_event')
      subject.broadcast('my_other_event')
    end
  end

  describe 'deafen' do
    it 'silences listeners with an event name' do
      expect(self).to_not receive(:inspect)
      subject.listen('my_event', &my_proc)
      subject.deafen('my_event', &my_proc)
      subject.broadcast('my_event')
    end

    it 'does not silence other events' do
      expect(self).to receive(:inspect)
      subject.listen('my_event', &my_proc)
      subject.deafen('my_other_event', &my_proc)
      subject.broadcast('my_event')
    end

    it 'can accept multiple event names' do
      expect(self).to_not receive(:inspect)
      subject.listen('my_event', &my_proc)
      subject.listen('my_other_event', &my_proc)
      subject.deafen('my_event', 'my_other_event', &my_proc)
      subject.broadcast('my_event')
      subject.broadcast('my_other_event')
    end
  end

  describe 'clear' do
    it 'empties the listeners' do
      expect(self).to_not receive(:inspect)
      subject.listen('my_event', &my_proc)
      subject.clear
      subject.broadcast('my_event')
    end
  end
end
