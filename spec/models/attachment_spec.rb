require 'rails_helper'

 describe Attachment do

   let(:attachment) { create :attachment, filename: nil, location: nil, file: fixture_for('images/strongbad.png') }
   let(:pdf_attachment) { create :attachment, file: fixture_for('strongmad.pdf')}
   let(:old_attachment) { create :attachment, filename: 'strongsad.png', filesize: 100, file_content_type: 'png', location: 'bucket.amazon.com/strongsad.png' }

   describe 'file' do
     it 'is backwards compatible with existing attachments' do
       expect(old_attachment.original).to eq old_attachment.location
       expect(old_attachment.filetype).to eq 'png'
     end

   end

 end
