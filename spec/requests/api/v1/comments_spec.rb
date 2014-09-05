require 'rails_helper'
describe "Comments API v1" do
  before do
    @user = FactoryGirl.create(:user)
    @discussion = FactoryGirl.create(:discussion)
    @discussion.group.add_member!(@user)
  end

  describe "create" do
    let(:comment_params) { {comment: {body: "hi there", discussion_id: @discussion.id}} }
    let(:common_headers) { { 'Loomio-User-Id' => @user.id } }

    context "not authenticated" do
      let(:request_headers) { common_headers }

      it "rejects incorrect authentication" do
        post '/api/v1/comments', comment_params, request_headers
        expect(response.status).to eq(401)
      end
    end

    context "authenticated" do
      let(:request_headers) { common_headers.merge({'Loomio-Email-API-Key' => @user.email_api_key}) }

      it "creates a comment" do
        post '/api/v1/comments', comment_params, request_headers
        expect(response.code.to_i).to eq(200)
        expect(@discussion.reload.comments.last.author).to eq(@user)
        expect(@discussion.reload.comments.last.body).to eq(comment_params[:comment][:body])
      end
    end
  end
end
