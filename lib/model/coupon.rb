module Magentwo
  class Coupon < Base
    Attributes = %i(coupon_id rule_id code usage_per_customer times_used is_primary type)
    Attributes.each do |attr| attr_accessor attr end

    class << self
      def get_path
        "#{base_path}/search"
      end

      def generate rule_id, quantity:1, length:16, format:(:alpha), delimiter:"-", delimiter_at_every:4
        format = format.to_sym
        Magentwo::Validator.one_of format, :num, :alpha, :alphanum
        self.call :post, "#{base_path}/generate",
        {
          :couponSpec => {
           :rule_id => rule_id,
           :quantity => quantity,
           :length => length,
           :format => format,
           :delimiter => delimiter,
           :delimiter_at_every => delimiter_at_every
          }
        }
      end

      def unique_identifier
        :coupon_id
      end
    end

  end
end
