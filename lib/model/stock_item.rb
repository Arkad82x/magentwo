# Usage: 
# Magentwo::StockItems['sku']

module Magentwo
  class StockItem < Base
    Attributes = %i(item_id product_id stock_id qty is_in_stock is_qty_decimal show_default_notification_message use_config_min_qty min_qty use_config_min_sale_qty min_sale_qty use_config_max_sale_qty max_sale_qty use_config_backorders backorders use_config_notify_stock_qty notify_stock_qty use_config_qty_increments qty_increments use_config_enable_qty_inc enable_qty_increments use_config_manage_stock manage_stock low_stock_date is_decimal_divided stock_status_changed_auto)
    Attributes.each do |attr| attr_accessor attr end

    class << self
      def unique_identifier
        'item_id'
      end
    end
  end
end
