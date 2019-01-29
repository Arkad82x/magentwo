module Magentwo
  class Base
    DatasetMethods = %i(filter exclude select fields count fields info page order_by like)

    attr_accessor :base_path

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

    def save
      self.validate
      response = self.connection.put self.class.base_path, self.to_h
      self.class.new response
    end

    def delete
      self.connection.delete self.class.base_path, self.to_h
    end

    def validate
      true
    end

    def check_presence *attributes
      Magentwo::Validator.check_presence self, attributes
    end

    def call method, path, params
      self.class.call method, path, params
    end

    class << self
      attr_accessor :connection

      def base_path
        "#{self.name.split(/::/).last.downcase}s"
      end

      def all ds=self.dataset
        self.get(ds.to_query)
        .map do |item|
          self.new item
        end
      end

      def first ds=self.dataset
        self.new self.get(ds.page(1, 1).to_query).first
      end

      def dataset
        Magentwo::Dataset.new(self)
      end

      DatasetMethods.each do |name|
        define_method name do |*args|
          return dataset.send(name, *args)
        end
      end

      def get query, path:self.base_path, meta_data:false
        case meta_data
        when true then self.call :get_with_meta_data, path, query
        when false then self.call :get, path, query
        else
          raise ArgumentError "unknown meta_data param, expected bool value. got: #{meta_data}"
        end
      end

      def call method, path=self.base_path, params
          Magentwo::Base.connection.send(method, path, params)
      end
    end
  end
end
