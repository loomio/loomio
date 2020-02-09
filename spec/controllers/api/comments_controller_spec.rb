require 'rails_helper'
describe API::CommentsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :formal_group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:another_comment) { create :comment, discussion: discussion, author: another_user }

  before do
    group.add_member! user
    DiscussionService.create(discussion: discussion, actor: discussion.author)
  end

  describe "signed in" do
    before do
      sign_in user
    end

    describe 'update' do
      let(:comment_params) { {body: 'updated content'} }

      context 'success' do
        it "updates a comment" do
          post :update, params: { id: comment.id, comment: comment_params }
          expect(response.status).to eq 200
          expect(comment.reload.body).to eq comment_params[:body]
        end
      end

      context 'failures' do
        it "responds with an error when there are unpermitted params" do
          comment_params[:dontmindme] = 'wild wooly byte virus'
          put :update, params: { id: comment.id, comment: comment_params }
          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['exception']).to include 'ActionController::UnpermittedParameters'
        end

        it "responds with an error when the user is unauthorized" do
          put :update, params: {id: another_comment.id, comment: comment_params}
          expect(response.status).to eq 403
          expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
        end

        it "responds with validation errors when they exist" do
          comment_params[:body] = ''
          put :update, params: { id: comment.id, comment: comment_params }
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
          post :create, params: { comment: comment_params }
          expect(response.status).to eq 200
          expect(Comment.where(body: comment_params[:body],
                               user_id: user.id)).to exist
        end

        it "prevents xss src" do
          post :create, params: { comment: {discussion_id: discussion.id, body: "<img src=\"javascript:alert('hi')\" >hello", body_format: "html"} }
          expect(response.status).to eq 200
          expect(Comment.last.body).to eq "<img>hello"
        end

        it "prevents xss href" do
          post :create, params: { comment: {discussion_id: discussion.id, body: "<a href=\"javascript:alert('hi')\" >hello</a>", body_format: "html"} }
          expect(response.status).to eq 200
          expect(Comment.last.body).to eq "<a rel=\"nofollow ugc noreferrer noopener\" target=\"_blank\">hello</a>"
        end

        it 'allows guest group members to comment' do
          discussion.group.memberships.find_by(user: user).destroy
          discussion.guest_group.add_member! user

          post :create, params: { comment: comment_params }
          expect(response.status).to eq 200
          expect(Comment.where(body: comment_params[:body],
                               user_id: user.id)).to exist
        end

        it 'responds with a discussion with a reader' do
          post :create, params: { comment: comment_params }
          json = JSON.parse(response.body)
          expect(json['discussions'][0]['discussion_reader_id']).to be_present
        end

        it 'responds with json' do
          post :create, params: { comment: comment_params }
          json = JSON.parse(response.body)
          expect(json.keys).to include *(%w[users comments])
        end

        describe 'mentioning' do
          it 'mentions appropriate users' do
            group.add_member! another_user
            comment_params[:body] = "Hello, @#{another_user.username}!"
            expect { post :create, params: { comment: comment_params }, format: :json }.to change { Event.where(kind: :user_mentioned).count }.by(1)
          end

          it 'invites non-members to the discussion' do
            comment_params[:body] = "Hello, @#{another_user.username}!"
            expect { post :create, params: { comment: comment_params }, format: :json }.to change { discussion.guest_group.memberships.count }.by(1)
          end
        end
      end

      context 'failures' do
        it "responds with an error when there are unpermitted params" do
          comment_params[:dontmindme] = 'wild wooly byte virus'
          put :update, params: { id: comment.id, comment: comment_params }
          expect(JSON.parse(response.body)['exception']).to include 'ActionController::UnpermittedParameters'
        end

        it "responds with an error when the user is unauthorized" do
          sign_in another_user
          put :update, params: { id: comment.id, comment: comment_params }
          expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
        end

        it "responds with validation errors when they exist" do
          comment_params[:body] = ''
          post :create, params: { comment: comment_params }
          json = JSON.parse(response.body)
          expect(response.status).to eq 422
          expect(json['errors']['body']).to include 'Comment cannot be empty'
        end
      end
    end

    describe 'destroy' do
      context 'allowed to delete' do
        it "destroys a comment" do
          CommentService.create(comment: comment, actor: user)
          delete :destroy, params: { id: comment.id }
          expect(response.status).to eq 200
          expect(Comment.where(id: comment.id).count).to be 0
        end
      end

      context 'not allowed to delete' do
        it "gives error of some kind" do
          CommentService.create(comment: another_comment, actor: another_user)
          delete(:destroy, params: { id: another_comment.id })
          expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
          expect(Comment.where(id: another_comment.id)).to exist
        end
      end
    end
  end
end
