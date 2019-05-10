require 'ostruct'

module Magentwo
  class Category < Base
    Attributes = %i(id parent_id name is_active position level product_count children_data)
    Attributes.each do |attr| attr_accessor attr end

    class << self
      
      # Getting all categories and nested categories from /categories
      def get_categories
        @categories = []
        result = Magentwo::Base.adapter.call(:get, 'categories', '')
        object = JSON.parse(result.to_json, object_class: OpenStruct)
        parse_categories(object)
        return @categories
      end

      # Loop recursively through all categories, build an OStruct for each category
      # Append the category object to @categories
      def parse_categories(categories)
        @categories << build_category(categories)
        categories.children_data.each do |category|
          parse_categories(category)
        end
      end
      
      def build_category(object)
        category = OpenStruct.new
        Magentwo::Category::Attributes.each do |attr| 
          category[attr] = object[attr] unless attr == :children_data
        end
        return category
      end  


      # Based on the Mangeto Swagger Documentation the correct base path is "categories/list"
      # However, I working with more than 10k categories and I'm receiving a Net::ReadTimeout (Net::ReadTimeout) error
      # and the page limit filter doesn't seem to be working so I built the Get Cateogires method above.
      
      def base_path
        "categories/list"
      end
    end
  end
end
