require "rails_helper"

RSpec.describe "Users" do
  describe "GET /users" do
    before { get "/users" }

    it "returns ok status", :aggregate_failures do
      payload = response.parsed_body
      expect(payload).to be_empty
      expect(response).to have_http_status(:ok)
    end

    context "with users in the database" do
      let!(:users) { create_list(:user, 10) }

      it "returns all the users", :aggregate_failures do
        get "/users"
        payload = response.parsed_body
        expect(payload.size).to eq(users.size)
        expect(response).to have_http_status(:ok)
        expect(payload).to eq(users.as_json)
      end
    end

    context "without users in the database" do
      it "returns empty payload", :aggregate_failures do
        payload = response.parsed_body
        expect(payload).to be_empty
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /users/:id" do
    context "when the record exists" do
      let(:user) { create(:user) }

      before { get "/users/#{user.id}" }

      it "returns user", :aggregate_failures do
        payload = response.parsed_body
        expect(response).to have_http_status(:ok)
        expect(payload).to eq(user.as_json)
      end
    end

    context "when the record does not exist" do
      let(:user_id) { 100 }

      before { get "/users/#{user_id}" }

      it { expect(response).to have_http_status(:not_found) }

      it "returns not found message", :aggregate_failures do
        payload = response.parsed_body
        expect(payload["message"]).to eq("Couldn't find User with 'id'=#{user_id}")
      end
    end
  end

  describe "POST /users" do
    subject(:payload) { response.parsed_body }

    context "when the user is valid" do
      let(:user) { build(:user) }

      before { post "/users", params: user.as_json }

      it { expect(response).to have_http_status(:created) }
      it { expect(User.count).to eq(1) }
      it { expect(payload["id"]).to eq(User.last.id) }
      it { expect(payload["email"]).to eq(user.email) }
      it { expect(payload["name"]).to eq(user.name) }
    end

    context "when the request is invalid" do
      let(:user) { User.new }

      before { post "/users", params: user.as_json }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(User.count).to eq(0) }
      it { expect(payload["errors"]).to be_present }
    end
  end

  describe "PUT /users/:id" do
    let(:user) { create(:user) }
    let(:changes) { { name: "John" } }

    before { put "/users/#{user.id}", params: changes }

    context "when the record exists" do
      it { expect(response).to have_http_status(:ok) }

      it "returns updated user", :aggregate_failures do
        payload = response.parsed_body
        expect(payload).to eq(user.reload.as_json)
      end
    end

    context "when the record does not exist" do
      it "returns not found message", :aggregate_failures do
        put "/users/100", params: changes
        payload = response.parsed_body
        expect(response).to have_http_status(:not_found)
        expect(payload["message"]).to eq("Couldn't find User with 'id'=100")
      end
    end

    context "when the request is invalid" do
      let(:changes) { { email: nil } }

      it { expect(response).to have_http_status(:unprocessable_entity) }

      it "returns validation errors", :aggregate_failures do
        payload = response.parsed_body
        expect(payload["errors"]).to be_present
        expect(payload["errors"]["email"]).to include("can't be blank")
      end
    end
  end

  describe "DELETE /users/:id" do
    let!(:user) { create(:user) }

    before { delete "/users/#{user.id}" }

    context "when the record exists" do
      it { expect(response).to have_http_status(:no_content) }
      it { expect(User.count).to eq(0) }
    end

    context "when the record does not exist" do
      it "returns not found message", :aggregate_failures do
        delete "/users/100"
        payload = response.parsed_body
        expect(response).to have_http_status(:not_found)
        expect(payload["message"]).to eq("Couldn't find User with 'id'=100")
      end
    end
  end
end
