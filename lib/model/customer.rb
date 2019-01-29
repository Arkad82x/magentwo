module Magentwo
  class Customer < Base
    Attributes = %i(id group_id default_billing default_shipping created_at updated_at created_in dob email firstname lastname gender store_id website_id addresses disable_auto_group_change extension_attributes)
    Attributes.each do |attr| attr_accessor attr end

    def with_extension_attributes
      self.class.new (self.class.get nil, path:"customers/#{self.id}")
    end

    def validate
      check_presence :email
      super
    end

    class << self
      def get_path
        "#{base_path}/search"
      end
    end
  end
end
