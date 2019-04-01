module Magentwo
  class Base
    DatasetMethods = %i(filter exclude select fields count fields info page order_by like gt lt gteq lteq from to)

    def initialize args
      args.each do |key, value|
        key_sym = :"@#{key}"
        if self.respond_to? :"#{key}="
          instance_variable_set key_sym, value
        end
      end
      if self.respond_to?(:custom_attributes) && args[:custom_attributes]
        self.custom_attributes = args[:custom_attributes].map do |attr|
          Hash[attr[:attribute_code].to_sym, attr[:value]]
        end.inject(&:merge)
      end
    end

    def save
      self.validate
      self.check_presence self.class.unique_identifier
      response = Magentwo::Base.call :put, "#{self.class.base_path}/#{self.send(self.class.unique_identifier)}", self
      self.class.new response
    end

    def delete
      self.check_presence self.class.unique_identifier
      Magentwo::Base.call :delete, "#{self.class.base_path}/#{self.send(self.class.unique_identifier)}", nil
    end

    def validate
      true
    end

    def check_presence *attributes
      Magentwo::Validator.check_presence self, *attributes
    end

    def call method, path, params
      self.class.call method, path, params
    end

    def to_h
      self.instance_variables.map do |k|
        key = k.to_s[1..-1] #symbol to string and remove @ in front
        if key == "custom_attributes"
          [
            key,
            self.send(key).map do |k, v|
              {:attribute_code => k, :value => v}
            end
          ]
        else
          [key, self.send(key)]
        end
      end
      .to_h
    end

    def to_json
      Hash[self.class.lower_case_name, self.to_h].to_json
    end

    class << self
      attr_accessor :adapter

      def [] unique_identifier_value
        result = Magentwo::Base.get nil, path:"#{base_path}/#{unique_identifier_value}"
        self.new result if result
      end

      def unique_identifier
        :id
      end

      def lower_case_name
        name = self.name.split(/::/).last
        "#{name[0,1].downcase}#{name[1..-1]}"
      end

      def base_path
        "#{lower_case_name}s"
      end

      def get_path
        base_path
      end

      def all ds=self.dataset, meta_data:false
        response = self.get(ds.to_query, :meta_data => meta_data)
        return [] if response.nil?
        items = (meta_data ? response[:items] : response)
        .map do |item|
          self.new item
        end
        if meta_data
          response[:items] = items
          response
        else
          items
        end
      end

      def first ds=self.dataset
        response = self.get(ds.page(1, 1).to_query).first
        self.new response if response
      end

      def each_page page_size=Magentwo.default_page_size, &block
        self.dataset.each_page page_size, &block
      end

      def each &block
        self.dataset.each &block
      end

      def map &block
        self.dataset.map &block
      end

      def dataset
        Magentwo::Dataset.new(self)
      end

      DatasetMethods.each do |name|
        define_method name do |*args|
          return dataset.send(name, *args)
        end
      end

      def get query, path:self.get_path, meta_data:false
        case meta_data
        when true then self.call :get_with_meta_data, path, query
        when false then self.call :get, path, query
        else
          raise ArgumentError "unknown meta_data param, expected bool value. got: #{meta_data}"
        end
      end

      def call method, path=self.base_path, params
        Magentwo::Base.adapter.call(method, path, params)
      end

    end
  end
end
