require 'rails_helper'

ENV['REPLY_HOSTNAME'] = 'replyhostname.com'

describe EmailHelper do
  context 'reply_to_address' do
    let(:discussion) { double(:discussion, id: 'd1') }
    let(:user) { double(:user, id: '1', email_api_key: 'abc123') }
    it "gives correct format" do
      output = helper.reply_to_address(discussion: discussion,
                                          user: user)
      expect(output).to eq "d=d1&u=1&k=abc123@replyhostname.com"
    end
  end

  describe 'polymorphic_url' do
    let(:group) { create :formal_group }
    let(:discussion) { create :discussion }
    let(:comment) { create :comment }
    let(:utm_hash) { { utm_medium: "wark" }}

    it 'returns a discussion url' do
      expect(helper.polymorphic_url(discussion)).to match "/d/#{discussion.key}"
    end

    it 'returns a group url' do
      expect(helper.polymorphic_url(group)).to match "/g/#{group.key}"
    end

    it 'returns a comment url' do
      expect(helper.polymorphic_url(comment)).to match "/d/#{comment.discussion.key}/comment/#{comment.id}"
    end

    it 'can accept a utm hash' do
      expect(helper.polymorphic_url(comment, utm_hash)).to match "utm_medium=wark"
    end
  end
end
