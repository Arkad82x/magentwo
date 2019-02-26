module Magentwo
  class Order < Base
    Attributes = %i(base_currency_code base_discount_amount base_discount_invoiced base_grand_total base_discount_tax_compensation_amount base_discount_tax_compensation_invoiced base_shipping_amount base_shipping_discount_amount base_shipping_discount_tax_compensation_amnt base_shipping_incl_tax base_shipping_invoiced base_shipping_tax_amount base_subtotal base_subtotal_incl_tax base_subtotal_invoiced base_tax_amount base_tax_invoiced base_total_due base_total_invoiced base_total_invoiced_cost base_total_paid base_to_global_rate base_to_order_rate billing_address_id created_at customer_dob customer_email customer_firstname customer_gender customer_group_id customer_id customer_is_guest customer_lastname customer_note_notify discount_amount discount_invoiced entity_id global_currency_code grand_total discount_tax_compensation_amount discount_tax_compensation_invoiced increment_id is_virtual order_currency_code protect_code quote_id shipping_amount shipping_description shipping_discount_amount shipping_discount_tax_compensation_amount shipping_incl_tax shipping_invoiced shipping_tax_amount state status store_currency_code store_id store_name store_to_base_rate store_to_order_rate subtotal subtotal_incl_tax subtotal_invoiced tax_amount tax_invoiced total_due total_invoiced total_item_count total_paid total_qty_ordered updated_at weight items billing_address payment status_histories extension_attributes amount_refunded base_amount_refunded base_discount_amount base_discount_invoiced base_discount_tax_compensation_amount base_discount_tax_compensation_invoiced base_original_price base_price base_price_incl_tax base_row_invoiced base_row_total base_row_total_incl_tax base_tax_amount base_tax_invoiced created_at discount_amount discount_invoiced discount_percent free_shipping discount_tax_compensation_amount discount_tax_compensation_invoiced is_qty_decimal item_id name no_discount order_id original_price price price_incl_tax product_id product_type qty_canceled qty_invoiced qty_ordered qty_refunded qty_shipped row_invoiced row_total row_total_incl_tax row_weight sku store_id tax_amount tax_invoiced tax_percent updated_at weight)
    Attributes.each do |attr| attr_accessor attr end

    def products
      product_skus = self.items.map do |item|
        item[:sku]
      end
      Magentwo::Product.filter(:sku => product_skus).all
    end

    def customer
      Magentwo::Customer[self.customer_id]
    end

    class << self
      #this is necessary as the return type of magento2 is not consistent
      def [] unique_identifier
        self.filter(:entity_id => unique_identifier).first
      end

      def unique_identifier
        Magentwo::Logger.error "orders do not container id on default requests, therefore they cannot be targeted on the API"
        nil
      end
    end
  end
end
