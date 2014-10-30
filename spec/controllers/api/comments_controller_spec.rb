require 'rails_helper'
describe API::CommentsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:another_comment) { create :comment, discussion: discussion, author: another_user }
  let(:comment_params) {{
    body: 'Yo dawg those kittens be trippin for some dippin',
    discussion_id: discussion.id
  }}

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    sign_in user
  end

  describe 'index' do
    let(:other_discussion)         { create :discussion, group: group }
    let(:my_comment)               { create :comment, user: user, discussion: discussion }
    let(:my_other_comment)         { create :comment, user: user, discussion: other_discussion }
    let(:other_guys_comment)       { create :comment, user: another_user, discussion: discussion }
    let(:other_guys_other_comment) { create :comment, user: another_user, discussion: other_discussion }

    before do
      my_comment; my_other_comment; other_guys_comment; other_guys_other_comment
    end

    context 'success' do
      it 'returns comments filtered by discussion' do
        get :index, discussion_id: discussion.id, format: :json
        json = JSON.parse(response.body)

        comments = json['comments'].map { |c| c['id'] }
        expect(comments).to include my_comment.id
        expect(comments).to include other_guys_comment.id
        expect(comments).to_not include my_other_comment.id
      end
    end

    context 'failure' do
      it 'does not allow access to an unauthorized discussion' do
        cant_see_me = create :discussion
        expect { get :index, discussion_id: cant_see_me.id, format: :json }.to raise_error
      end
    end
  end

  describe 'like' do
    context 'success' do
      it "likes the comment" do
        post :like, id: comment.id, format: :json
        expect(comment.reload.likers).to include user
      end
    end

    context 'failure' do
      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { post :like, id: comment.id, format: :json }.to raise_error
      end
    end
  end

  describe 'unlike' do
    context 'success' do
      it "unlikes the comment" do
        comment.likers << user
        post :unlike, id: comment.id, format: :json
        expect(comment.reload.likers).to_not include user
      end
    end

    context 'failure' do
      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { post :unlike, id: comment.id, format: :json }.to raise_error
      end
    end
  end

  describe 'update' do
    context 'success' do
      it "updates a comment" do
        post :update, id: comment.id, comment: comment_params, format: :json
        expect(response).to be_success
        expect(comment.reload.body).to eq comment_params[:body]
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        comment_params[:dontmindme] = 'wild wooly byte virus'
        expect { put :update, id: comment.id, comment: comment_params, format: :json }.to raise_error 
      end

      it "responds with an error when the user is unauthorized" do
        expect { put :update, id: another_comment.id, comment: comment_params, format: :json }.to raise_error
      end

      it "responds with validation errors when they exist" do
        comment_params[:body] = ''
        put :update, id: comment.id, comment: comment_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(json['errors']['body']).to include 'Comment cannot be empty'
      end
    end
  end

  describe 'create' do
    context 'success' do
      it "creates a comment" do
        post :create, comment: comment_params, format: :json
        expect(response).to be_success
        expect(Comment.last).to be_present
      end

      it 'responds with json' do
        post :create, comment: comment_params, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users attachments comments])
        expect(json['comments'][0].keys).to include *(%w[
          id 
          body
          discussion_id
          created_at
          updated_at
          liker_ids
          author_id
          parent_id
          attachment_ids
        ])
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        comment_params[:dontmindme] = 'wild wooly byte virus'
        expect { post :create, comment: comment_params, format: :json }.to raise_error 
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { post :create, comment: comment_params, format: :json }.to raise_error
      end

      it "responds with validation errors when they exist" do
        comment_params[:body] = ''
        post :create, comment: comment_params, format: :json
        json = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(json['errors']['body']).to include 'Comment cannot be empty'
      end

    end
  end

end
