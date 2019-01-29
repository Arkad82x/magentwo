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
      if self.respond_to?(:custom_attributes) && args[:custom_attributes]
        self.custom_attributes = args[:custom_attributes].map do |attr|
          Hash[attr[:attribute_code].to_sym, attr[:value]]
        end.inject(&:merge)
      end
    end

    def save
      self.validate
      response = Magentwo::Base.call :put, "#{self.class.base_path}/#{self.id}", self
      self.class.new response
    end

    def delete
      Magentwo.logger.warn "not implemented"
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
