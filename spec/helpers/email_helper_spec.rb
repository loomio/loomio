require 'rails_helper'

ENV['REPLY_HOSTNAME'] = 'replyhostname.com'

describe EmailHelper do
  context 'reply_to_address' do
    let(:discussion) { create(:discussion) }
    let(:comment) { create(:comment, discussion: discussion) }
    let(:user) { create(:user, email_api_key: 'abc123') }
    it "gives correct format" do
      output = helper.reply_to_address(model: discussion, user: user)
      expect(output).to eq "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@replyhostname.com"
    end

    it "gives correct format for a comment" do
      output = helper.reply_to_address(model: comment, user: user)
      expect(output).to eq "c=#{comment.id}&d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}@replyhostname.com"
    end
  end

  describe 'polymorphic_url' do
    let(:group) { create :formal_group, handle: nil }
    let(:group_handle) { create :formal_group }
    let(:discussion) { create :discussion }
    let(:comment) { create :comment }
    let(:utm_hash) { { utm_medium: "wark" }}

    it 'returns a discussion url' do
      expect(helper.send(:polymorphic_url, discussion)).to match "/d/#{discussion.key}"
    end

    it 'returns a group url' do
      expect(helper.send(:polymorphic_url, group)).to match "/g/#{group.key}"
    end

    it 'returns a group handle url' do
      expect(helper.send(:polymorphic_url, group_handle)).to match "/#{group.handle}"
    end

    it 'returns a comment url' do
      expect(helper.send(:polymorphic_url, comment)).to match "/d/#{comment.discussion.key}/comment/#{comment.id}"
    end

    it 'can accept a utm hash' do
      expect(helper.send(:polymorphic_url, comment, utm_hash)).to match "utm_medium=wark"
    end
  end
end
