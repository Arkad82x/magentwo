module Magentwo
  class Validator
    class << self
      def check_presence model, *attributes
        case model
        when Hash
          attributes.each do |attribute|
            raise ArgumentError, "#{attribute} must be set" unless model[attribute]
          end
        when Magentwo::Base
          attributes.each do |attribute|
            raise ArgumentError, "#{attribute} must be set" unless model.send(attribute)
          end
        else
          raise ArgumentError, "unknown model type, expected Child of Magentwo::Base or Hash"
        end
      end

      def one_of value, *valid_values
        raise ArgumentError, "value #{value} invalid, expected one of #{valid_values}" unless valid_values.include?value
      end
    end
  end
end
