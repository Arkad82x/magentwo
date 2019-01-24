module Magentwo
  class Customer < Base
    Attributes = %i(id group_id default_billing default_shipping created_at updated_at created_in dob email firstname lastname gender store_id website_id addresses disable_auto_group_change extension_attributes)

    Attributes.each do |attr|
      attr_accessor attr
    end

    def with_extension_attributes
      self.call :get, "customers/#{self.id}"
    end

    class << self
      def call method, path="customers/search", query:nil
        Magentwo::Base.connection.call method, path, {:query => query}
      end
    end
  end
end
