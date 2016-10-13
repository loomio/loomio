require 'rails_helper'
describe API::CommentsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:another_comment) { create :comment, discussion: discussion, author: another_user }

  before do
    group.members << user
  end

  describe "signed in" do
    before do
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
          post :like, id: comment.id
          expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
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
          put :update, id: comment.id, comment: comment_params
          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
        end

        it "responds with an error when the user is unauthorized" do
          put :update, {id: another_comment.id, comment: comment_params}
          expect(response.status).to eq 403
          expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
        end

        it "responds with validation errors when they exist" do
          comment_params[:body] = ''
          put :update, id: comment.id, comment: comment_params
          expect(response.status).to eq 422

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

        it 'responds with a discussion with a reader' do
          post :create, comment: comment_params
          json = JSON.parse(response.body)
          expect(json['discussions'][0]['discussion_reader_id']).to be_present
        end

        it 'responds with json' do
          post :create, comment: comment_params
          json = JSON.parse(response.body)
          expect(json.keys).to include *(%w[users comments])
        end

        describe 'mentioning' do
          it 'mentions appropriate users' do
            group.add_member! another_user
            comment_params[:body] = "Hello, @#{another_user.username}!"
            expect { post :create, comment: comment_params, format: :json }.to change { Event.where(kind: :user_mentioned).count }.by(1)
          end

          it 'does not mention users not in the group' do
            comment_params[:body] = "Hello, @#{another_user.username}!"
            expect { post :create, comment: comment_params, format: :json }.to_not change { Event.where(kind: :user_mentioned).count }
          end
        end
      end

      context 'failures' do
        it "responds with an error when there are unpermitted params" do
          comment_params[:dontmindme] = 'wild wooly byte virus'
          put :update, id: comment.id, comment: comment_params
          expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
        end

        it "responds with an error when the user is unauthorized" do
          sign_in another_user
          put :update, id: comment.id, comment: comment_params
          expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
        end

        it "responds with validation errors when they exist" do
          comment_params[:body] = ''
          post :create, comment: comment_params
          json = JSON.parse(response.body)
          expect(response.status).to eq 422
          expect(json['errors']['body']).to include 'Comment cannot be empty'
        end
      end
    end

    describe 'destroy' do
      context 'allowed to delete' do
        it "destroys a comment" do
          delete :destroy, id: comment.id
          expect(response).to be_success
          expect(Comment.where(id: comment.id).count).to be 0
        end
      end

      context 'not allowed to delete' do
        it "gives error of some kind" do
          delete(:destroy, id: another_comment.id)
          expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
          expect(Comment.where(id: another_comment.id)).to exist
        end
      end
    end
  end
end
