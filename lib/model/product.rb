module Magentwo
  class Product < Base
    Attributes = %i(id sku name attribute_set_id price status visibility type_id created_at updated_at extension_attributes product_links options media_gallery_entries tier_prices custom_attributes)
    Attributes.each do |attr| attr_accessor attr end

    def stocks
      Magentwo::StockItem[self.sku]
    end

    class << self
      def types
        Magentwo::Base.get nil, path:"#{base_path}/types"
      end

      def unique_identifier
        :sku
      end
    end
  end
end
