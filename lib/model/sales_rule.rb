module Magentwo
  class SalesRule < Base
    Attributes = %i(rule_id name store_labels description website_ids customer_group_ids uses_per_customer is_active condition action_condition stop_rules_processing is_advanced sort_order simple_action discount_amount discount_step apply_to_shipping times_used is_rss coupon_type use_auto_generation uses_per_coupon simple_free_shipping)
    Attributes.each do |attr| attr_accessor attr end

    def generate quantity:1, length:16, format:(:alpha), delimiter:"-", delimiter_at_every:4
      Magentwo::Coupon.generate self.rule_id, quantity:quantity, length:length, format:format, delimiter:delimiter, delimiter_at_every:delimiter_at_every
    end

    def coupons
      Magentwo::Coupon.filter(:rule_id => self.rule_id).all
    end


    class << self
      def get_path
        "#{base_path}/search"
      end

      def unique_identifier
        :rule_id
      end
    end

  end
end
