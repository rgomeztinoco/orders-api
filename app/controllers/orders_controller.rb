class OrdersController < ApplicationController
  before_action :set_order, only: %i[show update destroy]

  # GET /orders
  def index
    @orders = Order.all

    @orders =
      OrdersSearchService.by_delivered_at(
        @orders, params[:delivered_at]
      )

    render json: @orders, status: :ok
  end

  # GET /orders/:id
  def show
    render json: @order, status: :ok
  end

  # POST /orders
  def create
    @order = Order.new(create_params)
    if @order.save
      render json: @order, status: :created
    else
      render json: { errors: @order.errors }, status: :unprocessable_entity
    end
  end

  # PUT /orders/:id
  def update
    if @order.update(update_params)
      render json: @order, status: :ok
    else
      render json: { errors: @order.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /orders/:id
  def destroy
    @order.destroy
    head :no_content
  end

  private

  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { message: e.message }, status: :not_found
  end

  def create_params
    params.permit(:amount, :payment_status, :status, :user_id)
  end

  def update_params
    params.permit(:payment_status, :status)
  end
end
