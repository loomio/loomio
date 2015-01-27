require 'rails_helper'

shared_examples_for Searchable do

  let(:searchable) { build described_model_name, searchable_test_field => 'my test field' }

  describe 'search_vector' do
    it 'is created when the searchable is created' do
      searchable.save!
      expect(searchable.reload.search_vector).to be_present
      expect(searchable.search_vector.search_vector).to match /'test':2/
      expect(searchable.search_vector.search_vector).to match /'field':3/
    end

    it 'is updated when the searchable fields are updated' do
      searchable.save!
      searchable.update! searchable_test_field => 'new field val'
      expect(searchable.reload.search_vector).to be_present
      expect(searchable.search_vector.search_vector).to match /'field':2/
      expect(searchable.search_vector.search_vector).to match /'val':3/
    end
  end

end

def searchable_test_field
  case described_model_name.to_sym
  when :discussion then :title
  when :motion     then :name
  when :comment    then :body
  end
end