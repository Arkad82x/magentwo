module Magentwo
  class Customer < Base
    Attributes = %i(id group_id default_billing default_shipping created_at updated_at created_in dob email firstname lastname gender store_id website_id addresses disable_auto_group_change)

    Attributes.each do |attr|
      attr_accessor attr
    end

    class << self
      def call method, query
        model_name = "customers/search"
        Magentwo::Base.connection.call method, model_name, query
      end
    end
  end
end
