require 'rails_helper'

describe MigrateAttachmentService do
  let!(:discussion) { create :discussion }
  let!(:another_discussion) { create :discussion }
  let!(:attachment) { create :attachment, attachable: discussion, location: "https://www.example.com/image.jpg", filename: "image.jpg" }

  it 'creates a new document if the attachment is passed' do
    expect {
      MigrateAttachmentService.migrate! attachments: Attachment.where(attachable_type: "Discussion")
    }.to change { Document.count }.by(1)
    expect(attachment.reload.migrated_to_document).to eq true
    d = Document.last
    expect(d.model).to eq discussion
    expect(d.url).to eq attachment.url
    expect(d.title).to eq attachment.filename
  end

  it 'does not create a new document if the attachment is not passed' do
    expect {
      MigrateAttachmentService.migrate! attachments: Attachment.where(attachable_type: "Group")
    }.to_not change { Document.count }
    expect(attachment.reload.migrated_to_document).to eq false
  end
end
