require "test_helper"

class Api::V1::DocumentsControllerTest < ActionController::TestCase
  
  # Test for_group action with various group privacy levels
  
  # Open group tests
  test "for_group displays all documents for non-members in open group" do
    user = users(:normal_user)
    another_user = users(:another_user)
    group = groups(:test_group)
    group.update(group_privacy: 'open')

    # Create public discussions (open groups only allow public)
    discussion1 = create_discussion(group: group, author: user, private: false)
    discussion2 = create_discussion(group: group, author: user, private: false)

    # Create documents
    group_document = Document.create!(model: group, author: user, title: "Group Document",
      url: "https://example.com/group.pdf", doctype: "pdf", color: "#000000")
    disc1_document = Document.create!(model: discussion1, author: user, title: "Disc 1 Document",
      url: "https://example.com/disc1.pdf", doctype: "pdf", color: "#000000")
    disc2_document = Document.create!(model: discussion2, author: user, title: "Disc 2 Document",
      url: "https://example.com/disc2.pdf", doctype: "pdf", color: "#000000")

    sign_in another_user
    get :for_group, params: { group_id: group.id }
    json = JSON.parse(response.body)
    document_ids = json['documents'].map { |d| d['id'] }

    assert_includes document_ids, group_document.id
    assert_includes document_ids, disc1_document.id
    assert_includes document_ids, disc2_document.id
  end

  test "for_group displays all documents for members in open group" do
    user = users(:normal_user)
    group = groups(:test_group)
    group.update(group_privacy: 'open')

    # Create public discussions (open groups only allow public)
    discussion1 = create_discussion(group: group, author: user, private: false)
    discussion2 = create_discussion(group: group, author: user, private: false)

    # Create documents
    group_document = Document.create!(model: group, author: user, title: "Group Document",
      url: "https://example.com/group.pdf", doctype: "pdf", color: "#000000")
    disc1_document = Document.create!(model: discussion1, author: user, title: "Disc 1 Document",
      url: "https://example.com/disc1.pdf", doctype: "pdf", color: "#000000")
    disc2_document = Document.create!(model: discussion2, author: user, title: "Disc 2 Document",
      url: "https://example.com/disc2.pdf", doctype: "pdf", color: "#000000")

    sign_in user
    get :for_group, params: { group_id: group.id }
    json = JSON.parse(response.body)
    document_ids = json['documents'].map { |d| d['id'] }

    assert_includes document_ids, group_document.id
    assert_includes document_ids, disc1_document.id
    assert_includes document_ids, disc2_document.id
  end
  
  test "for_group displays all documents for visitors in open group" do
    user = users(:normal_user)
    group = groups(:test_group)
    group.update(group_privacy: 'open')

    # Create public discussions (open groups only allow public)
    discussion1 = create_discussion(group: group, author: user, private: false)
    discussion2 = create_discussion(group: group, author: user, private: false)

    # Create documents
    group_document = Document.create!(model: group, author: user, title: "Group Document",
      url: "https://example.com/group.pdf", doctype: "pdf", color: "#000000")
    disc1_document = Document.create!(model: discussion1, author: user, title: "Disc 1 Document",
      url: "https://example.com/disc1.pdf", doctype: "pdf", color: "#000000")
    disc2_document = Document.create!(model: discussion2, author: user, title: "Disc 2 Document",
      url: "https://example.com/disc2.pdf", doctype: "pdf", color: "#000000")

    get :for_group, params: { group_id: group.id }
    json = JSON.parse(response.body)
    document_ids = json['documents'].map { |d| d['id'] }

    assert_includes document_ids, group_document.id
    assert_includes document_ids, disc1_document.id
    assert_includes document_ids, disc2_document.id
  end
  
  # Closed group tests
  test "for_group displays all documents for members in closed group" do
    user = users(:normal_user)
    group = groups(:test_group)
    group.update(group_privacy: 'closed')

    # Create discussions
    discussion1 = create_discussion(group: group, author: user, private: true)
    discussion2 = create_discussion(group: group, author: user, private: true)
    
    # Create documents
    group_document = Document.create!(
      model: group,
      author: user,
      title: "Group Document",
      url: "https://example.com/group.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    discussion1_document = Document.create!(
      model: discussion1,
      author: user,
      title: "Discussion 1 Document",
      url: "https://example.com/disc1.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    discussion2_document = Document.create!(
      model: discussion2,
      author: user,
      title: "Discussion 2 Document",
      url: "https://example.com/disc2.pdf",
      doctype: "pdf",
      color: "#000000"
    )

    sign_in user
    get :for_group, params: { group_id: group.id }
    json = JSON.parse(response.body)
    document_ids = json['documents'].map { |d| d['id'] }

    assert_includes document_ids, group_document.id
    assert_includes document_ids, discussion1_document.id
    assert_includes document_ids, discussion2_document.id
  end

  # Secret group tests
  test "for_group unauthorized for non-members in secret group" do
    user = users(:normal_user)
    another_user = users(:another_user)
    group = groups(:test_group)
    group.update(group_privacy: 'secret')

    # Create discussions
    discussion = create_discussion(group: group, author: user, private: true)

    # Create documents
    Document.create!(model: group, author: user, title: "Group Document",
      url: "https://example.com/group.pdf", doctype: "pdf", color: "#000000")
    Document.create!(model: discussion, author: user, title: "Discussion Document",
      url: "https://example.com/disc.pdf", doctype: "pdf", color: "#000000")

    # Remove another_user from group
    group.memberships.where(user: another_user).destroy_all

    sign_in another_user
    get :for_group, params: { group_id: group.id }

    assert_response :forbidden
  end

  test "for_group displays all documents for members in secret group" do
    user = users(:normal_user)
    group = groups(:test_group)
    group.update(group_privacy: 'secret')

    # Create discussions
    discussion1 = create_discussion(group: group, author: user, private: true)
    discussion2 = create_discussion(group: group, author: user, private: true)

    # Create documents
    group_document = Document.create!(model: group, author: user, title: "Group Document",
      url: "https://example.com/group.pdf", doctype: "pdf", color: "#000000")
    discussion1_document = Document.create!(model: discussion1, author: user, title: "Discussion 1 Document",
      url: "https://example.com/disc1.pdf", doctype: "pdf", color: "#000000")
    discussion2_document = Document.create!(model: discussion2, author: user, title: "Discussion 2 Document",
      url: "https://example.com/disc2.pdf", doctype: "pdf", color: "#000000")

    sign_in user
    get :for_group, params: { group_id: group.id }
    json = JSON.parse(response.body)
    document_ids = json['documents'].map { |d| d['id'] }

    assert_includes document_ids, group_document.id
    assert_includes document_ids, discussion1_document.id
    assert_includes document_ids, discussion2_document.id
  end
  
  test "for_group forbidden for non-members in secret group with closed group check" do
    user = users(:normal_user)
    another_user = users(:another_user)
    group = groups(:test_group)
    group.update(group_privacy: 'secret', discussion_privacy_options: 'public_or_private')
    
    # Remove another_user from group
    group.memberships.where(user: another_user).destroy_all
    
    sign_in another_user
    get :for_group, params: { group_id: group.id }
    
    assert_response :forbidden
  end
  
  # Test for_discussion action
  test "for_discussion returns documents for the discussion and its comments" do
    user = users(:normal_user)
    group = groups(:test_group)
    
    # Create discussion with polls and comments
    discussion = create_discussion(group: group, author: user)
    
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: discussion,
      group: group,
      author: user
    )
    PollService.create(poll: poll, actor: user)
    
    comment = Comment.new(
      body: "Test comment",
      parent: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)
    
    # Create another discussion with polls and comments
    another_discussion = create_discussion(group: groups(:another_group), author: users(:discussion_author))
    
    another_poll = Poll.new(
      title: "Another Poll",
      poll_type: "proposal",
      discussion: another_discussion,
      author: users(:discussion_author)
    )
    PollService.create(poll: another_poll, actor: users(:discussion_author))
    
    another_comment = Comment.new(
      body: "Another comment",
      parent: another_discussion,
      author: users(:discussion_author)
    )
    CommentService.create(comment: another_comment, actor: users(:discussion_author))
    
    # Create documents
    discussion_document = Document.create!(
      model: discussion,
      author: user,
      title: "Discussion Document",
      url: "https://example.com/discussion.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    poll_document = Document.create!(
      model: poll,
      author: user,
      title: "Poll Document",
      url: "https://example.com/poll.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    comment_document = Document.create!(
      model: comment,
      author: user,
      title: "Comment Document",
      url: "https://example.com/comment.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    another_discussion_document = Document.create!(
      model: another_discussion,
      author: users(:discussion_author),
      title: "Another Discussion Document",
      url: "https://example.com/another_discussion.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    another_poll_document = Document.create!(
      model: another_poll,
      author: users(:discussion_author),
      title: "Another Poll Document",
      url: "https://example.com/another_poll.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    another_comment_document = Document.create!(
      model: another_comment,
      author: users(:discussion_author),
      title: "Another Comment Document",
      url: "https://example.com/another_comment.pdf",
      doctype: "pdf",
      color: "#000000"
    )
    
    sign_in user
    get :for_discussion, params: { discussion_id: discussion.id }
    
    assert_response :success
    
    json = JSON.parse(response.body)
    document_ids = json['documents'].map { |d| d['id'] }
    
    assert_includes document_ids, discussion_document.id
    assert_includes document_ids, poll_document.id
    assert_includes document_ids, comment_document.id
    refute_includes document_ids, another_discussion_document.id
    refute_includes document_ids, another_poll_document.id
    refute_includes document_ids, another_comment_document.id
  end
  
  test "for_discussion does not allow non-members to see the documents" do
    user = users(:normal_user)
    another_user = users(:another_user)
    group = groups(:test_group)
    
    # Create discussion
    discussion = create_discussion(group: group, author: user)
    
    # Remove another_user from group
    group.memberships.where(user: another_user).destroy_all
    
    sign_in another_user
    get :for_discussion, params: { discussion_id: discussion.id }
    
    assert_response :forbidden
  end
end
