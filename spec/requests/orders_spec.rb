require "rails_helper"

RSpec.describe "Orders" do
  describe "GET /orders" do
    before { get "/orders" }

    it "returns ok status", :aggregate_failures do
      expect(response).to have_http_status(:ok)
    end

    context "with orders in the database" do
      # * the delivered_at attribute is set automatically when the order status is set to delivered ("entregada")
      let!(:delivered_orders) { create_list(:delivered_order, 10) }
      let!(:preparing_orders) { create_list(:preparing_order, 10) }

      before { get "/orders" }

      it "returns all the orders", :aggregate_failures do
        payload = response.parsed_body
        all_orders = delivered_orders + preparing_orders
        expect(response).to have_http_status(:ok)
        expect(payload.size).to eq(all_orders.size)
        expect(payload).to eq(all_orders.as_json)
      end

      it "returns orders filtered by delivered_at", :aggregate_failures do
        get "/orders?delivered_at=#{Date.current}"
        payload = response.parsed_body
        expect(response).to have_http_status(:ok)
        expect(payload.size).to eq(delivered_orders.size)
        expect(payload).to eq(delivered_orders.as_json)
      end
    end

    context "without orders in the database" do
      it "returns empty payload", :aggregate_failures do
        payload = response.parsed_body
        expect(response).to have_http_status(:ok)
        expect(payload).to be_empty
      end
    end
  end

  describe "GET /orders/:id" do
    context "when the record exists" do
      let(:order) { create(:order) }

      before { get "/orders/#{order.id}" }

      it "returns order", :aggregate_failures do
        payload = response.parsed_body
        expect(response).to have_http_status(:ok)
        expect(payload).to eq(order.as_json)
      end
    end

    context "when the record does not exist" do
      let(:order_id) { 100 }

      before { get "/orders/#{order_id}" }

      it { expect(response).to have_http_status(:not_found) }

      it "returns not found message", :aggregate_failures do
        payload = response.parsed_body
        expect(payload["message"]).to eq("Couldn't find Order with 'id'=#{order_id}")
      end
    end
  end

  describe "POST /orders" do
    subject(:payload) { response.parsed_body }

    context "when the order is valid" do
      let(:user) { create(:user) }
      let(:order) { build(:order, user_id: user.id) }

      before do
        post "/orders", params: order.as_json
      end

      it { expect(response).to have_http_status(:created) }
      it { expect(Order.count).to eq(1) }
      it { expect(payload["id"]).to eq(Order.last.id) }
      it { expect(payload["amount"]).to eq(order.amount) }
      it { expect(payload["payment_status"]).to eq(order.payment_status) }
      it { expect(payload["status"]).to eq(order.status) }
      it { expect(payload["user_id"]).to eq(user.id) }
    end

    context "when the order is invalid" do
      let(:order) { Order.new }

      before { post "/orders", params: order.as_json }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(Order.count).to eq(0) }
      it { expect(payload["errors"]).to be_present }
    end
  end

  describe "PUT /orders/:id" do
    let(:order) { create(:order) }
    let(:changes) { { status: "en preparación" } }

    before { put "/orders/#{order.id}", params: changes }

    context "when the record exists" do
      it "returns order", :aggregate_failures do
        payload = response.parsed_body
        expect(response).to have_http_status(:ok)
        expect(payload).to eq(order.reload.as_json)
      end
    end

    context "when the record does not exist" do
      let(:order_id) { 100 }

      before { put "/orders/#{order_id}", params: changes }

      it { expect(response).to have_http_status(:not_found) }
    end

    context "when the record is invalid" do
      subject(:payload) { response.parsed_body }

      let(:changes) { { status: nil } }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(payload["errors"]).to be_present }
    end
  end

  describe "DELETE /orders/:id" do
    let(:order) { create(:order) }

    before { delete "/orders/#{order.id}" }

    context "when the record exists" do
      it { expect(response).to have_http_status(:no_content) }
      it { expect(Order.count).to eq(0) }
    end

    context "when the record does not exist" do
      let(:order_id) { 100 }

      before { delete "/orders/#{order_id}" }

      it { expect(response).to have_http_status(:not_found) }
    end
  end
end
