module Magentwo
  class Customer < Base
    class << self
      def call method, query
        model_name = "customers/search"
        Magentwo::Base.connection.call method, model_name, query
      end
    end
  end
end
