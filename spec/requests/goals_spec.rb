require 'rails_helper'

RSpec.describe "Goals", type: :request do
  let(:user) { create(:user) }

  before { sign_in user } # Devise::Test::IntegrationHelpers を利用

  describe "GET /index" do
    it "returns http success" do
      get goals_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_goal_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a goal and redirects" do
      post goals_path, params: {
        goal: { title: "Test Goal", description: "sample", success_criteria: "done", category_id: 1, visibility: "public" }
      }
      expect(response).to have_http_status(:redirect)
      expect(Goal.last.title).to eq("Test Goal")
    end
  end
end
