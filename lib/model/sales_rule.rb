module Magentwo
  class SalesRule < Base
    Attributes = %i(rule_id name store_labels description website_ids customer_group_ids uses_per_customer is_active condition action_condition stop_rules_processing is_advanced sort_order simple_action discount_amount discount_step apply_to_shipping times_used is_rss coupon_type use_auto_generation uses_per_coupon simple_free_shipping)
    Attributes.each do |attr| attr_accessor attr end

    class << self
      def base_path
        "salesRules/search"
      end
    end

  end
end
