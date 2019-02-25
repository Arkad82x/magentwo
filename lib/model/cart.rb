module Magentwo
  class Cart < Base
    Attributes = %i(id created_at updated_at is_active is_virtual items_count items_qty customer billing_address reserved_order_id orig_order_id currency customer_is_guest customer_note_notify customer_tax_class_id store_id)
    Attributes.each do |attr| attr_accessor attr end

    class << self
      def get_path
        "#{self.base_path}/search"
      end
    end
  end
end
