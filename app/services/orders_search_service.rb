class OrdersSearchService
  def self.by_delivered_at(orders, query)
    return orders if query.blank?

    query = query.to_date
    orders.where(delivered_at: query.all_day)
  end
end
