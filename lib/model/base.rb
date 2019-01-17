module Magentwo
  class Base
    class << self; attr_accessor :connection end

    class << self
      #args may container searchCriteria, fields, ...
      def call method, query
        model_name = "#{self.name.split("::").last.downcase}s"
        Magentwo::Base.connection.call method, model_name, query
      end

      def all
        call :get, self.dataset.to_query
      end

      def dataset
        Magentwo::Dataset.new(self, [])
      end

      %i(filter exclude select fields first count fields info page order_by like).each do |name|
        define_method name do |*args|
          return dataset.send(name, *args)
        end
      end

    end
  end
end
