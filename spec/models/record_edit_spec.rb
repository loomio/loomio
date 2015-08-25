require 'rails_helper'

RSpec.describe RecordEdit, type: :model do
  
  it 'captures an edit' do
    discussion = FactoryGirl.create(:discussion, title: 'hello')
    author = FactoryGirl.create(:user)
    discussion.title = 'changed'
    record_edit = RecordEdit.capture!(discussion, author)
    expect(record_edit.record).to be(discussion)
    expect(record_edit.author).to be(author)
    expect(record_edit.previous_values).to eq({"title" => 'hello'})
    expect(record_edit.new_values).to eq({"title" => 'changed'})
    expect(record_edit.persisted?).to be true
  end
end
