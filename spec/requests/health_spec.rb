require "rails_helper"

RSpec.describe "Health endpoint" do
  describe "/GET /health" do
    before { get "/health" }

    it "returns OK", :aggregate_failures do
      payload = response.parsed_body
      expect(payload).not_to be_empty
      expect(payload["api"]).to eq("OK")
    end

    it "returns status code 200" do
      expect(response).to have_http_status(:ok)
    end
  end
end
