require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /mypage" do
    it "returns http success" do
      get mypage_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /mypage/edit" do
    it "returns http success" do
      get edit_mypage_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /mypage" do
    it "updates profile and redirects" do
      patch mypage_path, params: {
        profile: { bio: "updated" }
      }
      expect(response).to have_http_status(:redirect)
      expect(user.reload.profile.bio).to eq("updated")
    end
  end
end
