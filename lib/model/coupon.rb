module Magentwo
  class Coupon < Base
    Attributes = %i(coupon_id rule_id code usage_per_customer times_used is_primary type)
    Attributes.each do |attr| attr_accessor attr end

    class << self
      def base_path
        "#{super}/search"
      end


      def generate params
        Magentwo::Validator.check_presence params, :rule_id, :quantity, :length
        Magentwo::Validator.one_of params[:format], :num, :alpha, :alphanum, "", nil
        Magentwo::Validator.set_if_unset params, :format, :alpha
        self.call :post, "coupons/generate", {:couponSpec => params}
      end
    end

  end
end
