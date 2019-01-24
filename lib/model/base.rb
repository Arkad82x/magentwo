module Magentwo
  class Base
    DatasetMethods = %i(all filter exclude select fields first count fields info page order_by like)

    def initialize args
      args.each do |key, value|
        key_sym = :"@#{key}"
        if self.respond_to? :"#{key}="
          instance_variable_set key_sym, value
        end
      end
      if self.respond_to? :custom_attributes
        self.custom_attributes = args[:custom_attributes].map do |attr|
          Hash[attr[:attribute_code].to_sym, attr[:value]]
        end.inject(&:merge)
      end
    end

    def call method, path, query:nil
      Magentwo::Base.call method, path, {:query => query}
    end

    class << self; attr_accessor :connection end

    class << self
      #args may container searchCriteria, fields, ...
      def call method, path="#{self.name.split("::").last.downcase}s", query:nil
        Magentwo::Base.connection.call method, path, {:query => query}
      end

      def dataset
        Magentwo::Dataset.new(self)
      end

      DatasetMethods.each do |name|
        define_method name do |*args|
          return dataset.send(name, *args)
        end
      end
    end
  end
end
