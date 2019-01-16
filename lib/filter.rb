module Magentwo
  class BaseFilter
    attr_accessor :field, :value
    def initialize field, value
      @field = field
      @value = value
    end

    def to_query idx
      [
      "searchCriteria[filter_groups][#{idx}][filters][0][field]=#{self.field}",
      "searchCriteria[filter_groups][#{idx}][filters][0][value]=#{URI::encode(self.value)}",
      "searchCriteria[filter_groups][#{idx}][filters][0][condition_type]=#{self.class.name.split("::").last.downcase}"]
      .join("&")
    end
  end

  class ArrayFilter < BaseFilter
    def to_query idx
      [
      "searchCriteria[filter_groups][#{idx}][filters][0][field]=#{self.field}",
      "searchCriteria[filter_groups][#{idx}][filters][0][value]=#{URI::encode(self.value.join(","))}",
      "searchCriteria[filter_groups][#{idx}][filters][0][condition_type]=#{self.class.name.split("::").last.downcase}"]
      .join("&")
    end
  end

  module Filter
    class Eq < Magentwo::BaseFilter
    end
    class Neq < Magentwo::BaseFilter
    end
    class In < Magentwo::ArrayFilter
    end
    class Nin < Magentwo::ArrayFilter
    end
  end
end
