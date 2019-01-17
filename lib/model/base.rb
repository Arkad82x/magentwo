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
    end

    class << self; attr_accessor :connection end

    class << self
      #args may container searchCriteria, fields, ...
      def call method, query
        model_name = "#{self.name.split("::").last.downcase}s"
        Magentwo::Base.connection.call method, model_name, query
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
