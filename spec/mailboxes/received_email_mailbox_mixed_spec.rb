require "rails_helper"

RSpec.describe ReceivedEmailMailbox, type: :mailbox do
  include ActionMailbox::TestHelper
  include Rails.application.routes.url_helpers

  let(:eml_path) { Rails.root.join("spec/fixtures/files/email_with_mixed_attachments.eml") }
  let(:raw_email) { File.read(eml_path) }
  let(:mail) { Mail.read_from_string(raw_email) }

  before do
    # Ensure blob URLs can be generated in tests
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"

    allow_any_instance_of(ReceivedEmail).to receive(:is_addressed_to_loomio?).and_return(true)
    allow_any_instance_of(ReceivedEmail).to receive(:is_auto_response?).and_return(false)
    allow(ReceivedEmailService).to receive(:route)
  end

  it "builds a ReceivedEmail with inline and regular attachments and rewrites cid references" do
    # Creates a persisted inbound email ready for your mailbox to process
    inbound_email = receive_inbound_email_from_source(mail.to_s)

    expect {
      described_class.receive(inbound_email)
    }.to change(ReceivedEmail, :count).by(1)

    email = ReceivedEmail.last

    #
    # HTML BODY
    #
    expect(email.body_html).to include("rails/active_storage/blobs/redirect/")
    expect(email.body_html).to include(".png")
    expect(email.body_html).to include("<img")

    #
    # ATTACHMENTS
    #
    expect(email.attachments.count).to eq(3)
    filenames = email.attachments.map { |a| a.filename.to_s }.sort
    expect(filenames).to match_array(["logo1.png", "logo2.png", "notes.txt"])

    inline_images = email.attachments.select { |a| a.filename.to_s.start_with?("logo") }
    expect(inline_images.all? { |a| a.blob.content_type == "image/png" }).to be(true)

    text_file = email.attachments.find { |a| a.filename.to_s == "notes.txt" }
    expect(text_file.blob.content_type).to eq("text/plain")
    expect(text_file.blob.download).to include("Some notes")

    #
    # HEADERS AND SERVICE CALL
    #
    expect(email.subject).to eq("Multiple attachments test")
    expect(email.from).to include("alice@example.com")
    expect(ReceivedEmailService).to have_received(:route).with(email)
  end
end
