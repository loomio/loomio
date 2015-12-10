require 'rails_helper'
describe MotionReader do

  describe '#viewed!' do
    let(:user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group) }
    let(:reader) { MotionReader.for(user: user, motion: motion) }
    let(:voter) { FactoryGirl.create(:user) }
    let(:discussion) { FactoryGirl.create(:discussion, group: group) }
    let(:motion) { FactoryGirl.create(:motion, discussion: discussion) }

    before do
      group.add_member!(user)
      group.add_member!(voter)
      Vote.create!(motion: motion, user: voter, position: 'no', created_at: 1.hour.ago)
      motion.reload
      Vote.create!(motion: motion, user: voter, position: 'yes')
    end

    context 'not called' do
      it "should have 1 unread vote" do
        expect(reader.unread_votes_count).to eq 1
      end

      it "should have 2 unread activity" do
        expect(reader.unread_activity_count).to eq 2
      end
    end

    context 'no arguments' do
      before do
        reader.viewed!
      end

      it 'marks all unique votes as read' do
        expect(reader.unread_votes_count).to eq 0
      end

      it 'marks all vote activity as read' do
        expect(reader.unread_activity_count).to eq 0
      end
    end

    context 'with a time halfway between the votes' do
      before do
        reader.viewed!(30.minutes.ago)
      end

      it 'marks all unique votes before time as read' do
        expect(reader.unread_votes_count).to eq 1
      end

      it 'marks all vote activity before time as read' do
        expect(reader.unread_activity_count).to eq 1
      end
    end
  end
end

