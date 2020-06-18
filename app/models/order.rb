class Order < ApplicationRecord

  has_many   :order_items, dependent: :destroy

  VALID_STATUS = %w(pending paid complete cancelled)
  validates :status, presence: true, inclusion: {in: VALID_STATUS}
  validates :name, presence: true, on: :update
  validates :credit_card_num, presence: true, on: :update
  validates :credit_card_exp, presence: true, on: :update
  validates :credit_card_cvv, presence: true, on: :update
  validates :customer_email,  presence: true, on: :update

  def checkout_order!
    return "Invalid cart" if self.status != "pending"
    return "Missing credit card information" if self.name.nil? ||
    self.credit_card_num.nil? || self.credit_card_exp.nil? || self.credit_card_cvv.nil?
    return "Missing customer email" if self.customer_email.nil?
    return "Missing address" if self.address.nil? || self.city.nil? || self.state.nil? || self.zip.nil?
    # begin transaction
    # checking if stock is still available
    self.order_items.each do |item|
      return "Quantity not available in stock" if item.quantity > item.product.stock
    end
    self.order_items.each do |item|
      item.product.stock -= item.quantity
      item.product.save
    end
    self.status = "paid"
    result = self.save
    # end transaction
    return result ? nil : "Error saving the order"
  end

  def ship_order!
    return "Order not paid" if self.status != "paid"
    self.status = "complete"
    return self.save ? nil : "Error saving the order"
  end

  def cancel_order!
    return "Order not paid" if self.status != "paid"
    self.status = "cancelled"
    return self.save ? nil : "Error saving the order"
  end

  def total_cost
    total = 0
    self.order_items.each do |item|
      total += item.subtotal
    end
    return total
  end

  def empty?
    return order_items.count == 0 
  end


  # this method should return a list of Order Items in this Order 
  # where the Order Item contains a Product that belongs to the current_merchant
  def order_items_by_merchant(current_merchant)
    # return self.order_items.where(product inside that Order_Item belongs to current_merchant)
  end
end