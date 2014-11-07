require 'rails_helper'
describe API::CommentsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:another_comment) { create :comment, discussion: discussion, author: another_user }

  before do
    group.admins << user
    sign_in user
  end

  describe 'like' do
    context 'success' do
      it "likes the comment" do
        post :like, id: comment.id
        expect(comment.reload.likers).to include user
      end
    end

    context 'failure' do
      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { post :like, id: comment.id }.to raise_error
      end
    end
  end

  describe 'unlike' do
    context 'success' do
      it "unlikes the comment" do
        comment.likers << user
        post :unlike, id: comment.id
        expect(comment.reload.likers).to_not include user
      end
    end

    context 'failure' do
      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { post :unlike, id: comment.id }.to raise_error
      end
    end
  end

  describe 'update' do
    let(:comment_params) { {body: 'updated content'} }

    context 'success' do
      it "updates a comment" do
        post :update, id: comment.id, comment: comment_params
        expect(response).to be_success
        expect(comment.reload.body).to eq comment_params[:body]
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        comment_params[:dontmindme] = 'wild wooly byte virus'
        expect { put :update, id: comment.id, comment: comment_params}.to raise_error
      end

      it "responds with an error when the user is unauthorized" do
        expect { put :update, {id: another_comment.id, comment: comment_params} }.to raise_error
      end

      it "responds with validation errors when they exist" do
        comment_params[:body] = ''
        put :update, id: comment.id, comment: comment_params
        expect(response.status).to eq 400

        json = JSON.parse(response.body)
        expect(json['errors']['body']).to include 'Comment cannot be empty'
      end
    end
  end

  describe 'create' do
    let(:comment_params) { {discussion_id: discussion.id,
                            body: 'original content'} }

    context 'success' do
      it "creates a comment" do
        post :create, comment: comment_params
        expect(response).to be_success
        expect(Comment.where(body: comment_params[:body],
                             user_id: user.id)).to exist
      end

      it 'responds with json' do
        post :create, comment: comment_params
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users attachments comments])
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        comment_params[:dontmindme] = 'wild wooly byte virus'
        expect { post :create, comment: comment_params }.to raise_error
      end

      it "responds with an error when the user is unauthorized" do
        sign_in another_user
        expect { post :create, comment: comment_params }.to raise_error
      end

      it "responds with validation errors when they exist" do
        comment_params[:body] = ''
        post :create, comment: comment_params
        json = JSON.parse(response.body)
        expect(response.status).to eq 400
        expect(json['errors']['body']).to include 'Comment cannot be empty'
      end
    end
  end

end
