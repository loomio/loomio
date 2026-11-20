require 'test_helper'

class BlobDownloadAccessTest < ActionDispatch::IntegrationTest
  test 'issued original and preview links track thread discard and restoration for signed-out readers' do
    discussion = discussions(:discussion)
    blob = upload_image
    discussion.files.attach(blob)
    representation = blob.representation(HasRichText::PREVIEW_OPTIONS)
    original = rails_blob_path(blob)
    preview = rails_representation_path(representation)
    paths = [
      original,
      preview,
      original.sub('/blobs/redirect/', '/blobs/'),
      preview.sub('/representations/redirect/', '/representations/')
    ]

    paths.each { |path| assert_download(path, :redirect) }
    range = { 'Range' => 'bytes=0-7' }
    get original, headers: range
    assert_response :redirect
    issued_storage_path = URI(response.location).request_uri
    get issued_storage_path, headers: range
    assert_response :partial_content
    assert_equal blob.download.byteslice(0, 8), response.body.b

    DiscussionService.discard(discussion: discussion, actor: discussion.author)
    assert discussion.files.attachments.exists?(blob_id: blob.id)
    paths.each { |path| assert_download(path, :not_found) }
    get original, headers: range
    assert_response :not_found
    head preview
    assert_response :not_found

    get issued_storage_path
    assert_response :success

    discussion.update!(discarded_at: nil, discarded_by: nil)
    discussion.topic.update!(discarded_at: nil, discarded_by: nil)
    paths.each { |path| assert_download(path, :redirect) }
  end

  test 'proxy URLs return 404 even for live originals and representations' do
    blob = upload_image
    discussions(:discussion).files.attach(blob)
    representation = blob.representation(HasRichText::PREVIEW_OPTIONS)

    [blob, representation].each do |file|
      assert_download(rails_storage_proxy_path(file), :not_found)
      head rails_storage_proxy_path(file)
      assert_response :not_found
    end
  end

  test 'a shared blob needs at least one live attachment, including a direct thread' do
    blob = upload_image
    discussion = discussions(:discussion)
    direct_discussion = discussions(:direct_discussion)
    discussion.files.attach(blob)
    direct_discussion.image_files.attach(blob)
    path = rails_blob_path(blob)

    discussion.update!(discarded_at: Time.current)
    assert_download(path, :redirect)
    direct_discussion.image_files.detach
    assert_download(path, :not_found)
  end

  test 'unattached blobs and attachments to missing records return 404' do
    blob = upload_image
    path = rails_blob_path(blob)
    assert_download(path, :not_found)
    assert_download(rails_representation_path(blob.representation(HasRichText::PREVIEW_OPTIONS)), :not_found)

    attachment = discussions(:discussion).files.attach(blob).attachments.last
    attachment.update_columns(record_id: -1)
    assert_download(path, :not_found)
    attachment.update_columns(record_type: 'Document')
    assert_download(path, :not_found)
  end

  test 'replies follow their enclosing thread and group' do
    comment = comments(:public_discussion_comment)
    reply = Comment.create!(parent: comment, user: users(:admin), body: 'A reply', body_format: 'html')
    discussion = comment.parent
    group = discussion.group
    blob = upload_image
    reply.files.attach(blob)
    path = rails_blob_path(blob)

    assert_download(path, :redirect)
    comment.update!(discarded_at: Time.current)
    assert_download(path, :redirect)
    reply.update!(discarded_at: Time.current)
    assert_download(path, :not_found)
    reply.update!(discarded_at: nil)
    discussion.topic.update!(discarded_at: Time.current)
    assert_download(path, :not_found)
    discussion.topic.update!(discarded_at: nil)
    group.discard!(actor: users(:admin))
    assert_download(path, :not_found)
    group.undiscard!
    assert_download(path, :redirect)
  end

  test 'attachments in a subgroup follow discard of the parent group' do
    discussion = discussions(:discussion_in_subgroup)
    group = discussion.group
    blob = upload_image
    discussion.files.attach(blob)
    path = rails_blob_path(blob)

    assert_download(path, :redirect)
    group.parent.update_columns(discarded_at: Time.current)
    assert group.reload.kept?
    assert_download(path, :not_found)
  end

  test 'published inbound email can serve its attached files and inline images' do
    group = groups(:group)
    mail = Mail.read_from_string(File.binread(Rails.root.join('spec/fixtures/files/email_with_mixed_attachments.eml')))
    mail.from = users(:admin).email
    mail.to = "#{group.handle}@#{ENV.fetch('REPLY_HOSTNAME')}"
    assert_difference 'Discussion.count', 1 do
      store_inbound_mail(mail).route
    end

    discussion = Discussion.order(:id).last
    sources = HasRichText.media_sources(discussion.body, discussion.body_format)
    assert_equal 2, sources.size
    sources.each { |src| assert_download(URI(src).path, :redirect) }
    file = discussion.files.find { |attachment| attachment.filename.to_s == 'notes.txt' }
    assert_download(rails_blob_path(file), :redirect)
    follow_redirect!
    assert_response :success
    assert_includes response.body, 'Some notes'
  end

  test 'the download link rebuilt for an imported attachment works signed out' do
    discussion = discussions(:discussion)
    url = 'https://source.example.test/files/exported.txt'
    stub_request(:get, url).to_return(body: 'imported attachment')
    GroupExportService.download_attachment({
      'record_type' => 'Discussion', 'name' => 'files', 'url' => url,
      'filename' => 'exported.txt', 'content_type' => 'text/plain'
    }, discussion.id)

    path = discussion.reload.attachments.sole.fetch('download_url')
    assert_download(path, :redirect)
    follow_redirect!
    assert_response :success
    assert_equal 'imported attachment', response.body
  end

  test 'an export email works without a session and its token expires after a week' do
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new('group export'), filename: 'export.csv')
    mail = UserMailer.group_export_ready(users(:admin).id, 'Exported Group', blob.signed_id, 'records@example.com')
    mail_html = Nokogiri::HTML((mail.html_part || mail).body.decoded)
    url = URI(mail_html.at_css('a[href*="/group_export_downloads/"]')['href'])
    assert_equal ['records@example.com'], mail.to
    assert_download(url.request_uri, :redirect)
    follow_redirect!
    assert_response :success
    assert_equal 'group export', response.body
    assert_match(/\Aattachment/, response.headers['Content-Disposition'])

    # Previously emailed exports used ordinary blob links.
    assert_download(rails_blob_path(blob), :not_found)
    signed_id = url.path.split('/')[2]
    assert_download(rails_service_blob_path(signed_id, blob.filename), :not_found)
    assert_download(group_export_download_path(blob.signed_id, blob.filename), :not_found)
    travel GroupExportDownload::LIFETIME + 1.second
    assert_download(url.request_uri, :not_found)
  end

  private

  def upload_image
    File.open(Rails.root.join('spec/fixtures/images/patrick.png')) do |file|
      ActiveStorage::Blob.create_and_upload!(io: file, filename: 'attachment.png')
    end
  end

  def assert_download(path, status)
    get path
    assert_response status, path
    assert_equal 'no-store', response.headers['Cache-Control'], path
  end
end
