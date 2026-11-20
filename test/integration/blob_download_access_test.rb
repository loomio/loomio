require 'test_helper'

class BlobDownloadAccessTest < ActionDispatch::IntegrationTest
  test 'issued original and preview links track thread discard and restoration for signed-out readers' do
    discussion = discussions(:discussion)
    blob = upload_image
    discussion.files.attach(blob)
    representation = blob.representation(HasRichText::PREVIEW_OPTIONS)
    original = rails_blob_path(blob)
    preview = rails_representation_path(representation)
    routes = {
      original => :redirect,
      preview => :redirect,
      rails_storage_proxy_path(blob) => :success,
      rails_storage_proxy_path(representation) => :success,
      original.sub('/blobs/redirect/', '/blobs/') => :redirect,
      preview.sub('/representations/redirect/', '/representations/') => :redirect
    }

    routes.each { |path, status| assert_download(path, status) }
    get original
    issued_storage_path = URI(response.location).request_uri
    proxy = rails_storage_proxy_path(blob)
    range = { 'Range' => 'bytes=0-7' }
    get proxy, headers: range
    assert_response :partial_content
    assert_equal blob.download.byteslice(0, 8), response.body.b
    assert_equal 'no-store', response.headers['Cache-Control']
    get issued_storage_path, headers: range
    assert_response :partial_content

    DiscussionService.discard(discussion: discussion, actor: discussion.author)
    assert discussion.files.attachments.exists?(blob_id: blob.id)
    routes.each_key { |path| assert_download(path, :not_found) }
    get proxy, headers: range
    assert_response :not_found
    head preview
    assert_response :not_found

    get issued_storage_path
    assert_response :success

    discussion.update!(discarded_at: nil, discarded_by: nil)
    discussion.topic.update!(discarded_at: nil, discarded_by: nil)
    routes.each { |path, status| assert_download(path, status) }
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
    path = rails_storage_proxy_path(blob)

    assert_download(path, :success)
    comment.update!(discarded_at: Time.current)
    assert_download(path, :success)
    reply.update!(discarded_at: Time.current)
    assert_download(path, :not_found)
    reply.update!(discarded_at: nil)
    discussion.topic.update!(discarded_at: Time.current)
    assert_download(path, :not_found)
    discussion.topic.update!(discarded_at: nil)
    group.discard!(actor: users(:admin))
    assert_download(path, :not_found)
    group.undiscard!
    assert_download(path, :success)
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
    assert_download(rails_storage_proxy_path(file), :success)
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

  test 'an unsaved upload preview is limited to its uploader and expires' do
    uploader = users(:user)
    other_user = users(:admin)
    sign_in(uploader)
    data = 'draft upload'
    post '/rails/active_storage/direct_uploads', params: {
      blob: {
        filename: 'draft.txt', content_type: 'text/plain', byte_size: data.bytesize,
        checksum: Digest::MD5.base64digest(data),
        metadata: { DraftUploadsController::UPLOADER_KEY => other_user.id }
      }
    }, as: :json
    assert_response :success
    upload = response.parsed_body
    blob = ActiveStorage::Blob.find_signed!(upload.fetch('signed_id'))
    blob.upload(StringIO.new(data))
    draft_path = "/draft_uploads/#{blob.signed_id}"

    assert_download(upload.fetch('download_url'), :not_found)
    assert_download(draft_path, :success)
    assert_equal data, response.body
    travel DraftUploadsController::PREVIEW_LIFETIME + 1.second do
      assert_download(draft_path, :not_found)
    end

    sign_in(other_user)
    assert_download(draft_path, :not_found)
    cookies.delete('session_id')
    assert_download(draft_path, :not_found)

    sign_in(uploader)
    discussion = discussions(:discussion)
    discussion.files.attach(blob)
    assert_download(draft_path, :not_found)
    discussion.update!(discarded_at: Time.current)
    assert_download(draft_path, :not_found)
    assert_download(upload.fetch('download_url'), :not_found)
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

  def sign_in(user)
    token = LoginToken.create!(user: user)
    post '/api/v1/sessions', params: { user: { email: user.email, code: token.code } }, as: :json
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
  end
end
