require 'rails_helper'

describe Group do
  describe '#add_member!' do
    let(:group) { build :group }
    let(:user)  { create :user }

    it 'adds a member' do
      Benchmark.bm(1000) do |bm|
        bm.report("Old:") { group.add_member! user }
        bm.report("New:") { group.new_add_member! user }
      end
    end
  end
end
