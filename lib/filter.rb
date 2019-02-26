module Magentwo
  module Filter
    class Compare
      attr_accessor :field, :value
      def initialize field, value
        @field = field
        @value = value
      end

      def to_query idx
        [
        "searchCriteria[filter_groups][#{idx}][filters][0][field]=#{self.field}",
        "searchCriteria[filter_groups][#{idx}][filters][0][value]=#{URI::encode(self.value.to_s)}",
        "searchCriteria[filter_groups][#{idx}][filters][0][condition_type]=#{self.class.name.split("::").last.downcase}"]
        .join("&")
      end

      def to_s
        "#{self.field} #{self.class.name.split("::").last.downcase} #{self.value}"
      end
    end

    class CompareArray < Compare
      def to_query idx
        [
        "searchCriteria[filter_groups][#{idx}][filters][0][field]=#{self.field}",
        "searchCriteria[filter_groups][#{idx}][filters][0][value]=#{URI::encode(self.value.map(&:to_s).join(","))}",
        "searchCriteria[filter_groups][#{idx}][filters][0][condition_type]=#{self.class.name.split("::").last.downcase}"]
        .join("&")
      end

      def to_s
        "#{self.field} #{self.class.name.split("::").last.downcase} #{self.value}"
      end
    end

    class Simple
      attr_accessor :key, :value
      def initialize key, value
        @key = key
        @value = value
      end

      def to_query idx=nil
        "searchCriteria[#{key}]=#{value}"
      end

      def to_s
        "#{self.key} == #{self.value}"
      end
    end

    class Multi
      attr_accessor :kvps
      def initialize kvps
        @kvps = kvps
      end

      def to_query idx=nil
        kvps.map do |kvp|
          "searchCriteria[#{kvp[:key]}]=#{kvp[:value]}"
        end.join("&")
      end

      def to_s
        self.kvps.map do |kvp|
          "#{kvp[:key]} = #{kvp[:value]}"
        end.join("\n")
      end
    end


    class Eq < Magentwo::Filter::Compare
    end

    class Neq < Magentwo::Filter::Compare
    end

    class In < Magentwo::Filter::CompareArray
    end

    class Nin < Magentwo::Filter::CompareArray
    end

    class Like < Magentwo::Filter::Compare
    end

    class Gt < Magentwo::Filter::Compare
    end

    class Lt < Magentwo::Filter::Compare
    end

    class Gteq < Magentwo::Filter::Compare
    end

    class Lteq < Magentwo::Filter::Compare
    end

    class From < Magentwo::Filter::Compare
    end

    class To < Magentwo::Filter::Compare
    end

    class PageSize < Magentwo::Filter::Simple
      def initialize value
        super(:page_size, value)
      end
    end

    class CurrentPage < Magentwo::Filter::Simple
      def initialize value
        super(:current_page, value)
      end
    end

    class OrderBy < Magentwo::Filter::Multi
      def initialize field, direction
        super([{:key => :field, :value => field}, {:key => :direction, :value => direction}])
      end

      def to_query idx=nil
        self.kvps.map do |kvp|
        "searchCriteria[sortOrders][0][#{kvp[:key]}]=#{kvp[:value]}"
        end.join("&")
      end
    end

    class Fields
      attr_accessor :fields
      def initialize fields
        @fields = fields
      end
      def to_query idx=nil
        #TODO api supports nested field selection e.g. items[address[street]]
        "fields=items[#{URI::encode(self.fields.map(&:to_s).join(","))}]"
      end
    end
  end
end
