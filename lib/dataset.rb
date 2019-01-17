module Magentwo
  class Dataset
    attr_accessor :model, :opts
    def initialize model, opts=nil
      self.model = model
      self.opts = opts || {
        :filters => [],
        :pagination => {
          :current_page => Filter::CurrentPage.new(1),
          :page_size => Filter::PageSize.new(20)
        },
        :ordering => []
      }
    end


    #################
    # Filters
    ################
    def filter args, invert:false
      filter = case args
      when Hash
        case args.values.first
        when Array
          unless invert
            Filter::In.new(args.keys.first, args.first.values.first)
          else
            Filter::Nin.new(args.keys.first, args.first.values.first)
          end
        else
          unless invert
            Filter::Eq.new(args.keys.first, args.values.first)
          else
            Filter::Neq.new(args.keys.first, args.values.first)
          end
        end
      else
        raise StandardError, "filter function expects Hash as input"
      end
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [filter])
    end

    def exclude args
      filter args, invert:true
    end

    def select *fields
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::Fields.new(fields)])
    end

    def like args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::Like.new(args.keys.first, args.values.first)])
    end

    #################
    # Pagination
    ################
    def page page, page_size=20
      Dataset.new self.model, self.opts.merge(:pagination => {:current_page => Filter::CurrentPage.new(page), :page_size => Filter::PageSize.new(page_size)})
    end

    #################
    # Ordering
    ################
    def order_by field, direction="ASC"
      Dataset.new self.model, self.opts.merge(:ordering => self.opts[:ordering] + [Filter::OrderBy.new(field, direction)])
    end

    #################
    # Fetching
    ################
    def info
      result = self.model.call :get, self.page(1, 1).to_query
      {
        :fields => result["items"]&.first&.keys,
        :total_count => result["total_count"]
      }
    end

    def count
      self.info[:total_count]
    end

    def fields
      self.info[:fields]
    end

    def first
      result = self.model.call :get, self.page(1, 1).to_query
      self.model.new result["items"].first
    end

    def all
      result = self.model.call :get, self.to_query
      return [] if result.nil?
      result["items"].map do |item|
        self.model.new item
      end
    end

    #################
    # Transformation
    ################
    def to_query
      #TODO this is a hack because api required searchCriteria to be set, so Magentwo::Product.all would lead to an error
      [
        self.opts[:filters]
        .each_with_index
        .map { |opt, idx| opt.to_query(idx) }
        .join("&"),

        self.opts[:pagination]
        .map { |k, v| v.to_query}
        .join("&"),


        self.opts[:ordering]
        .map { |opt, idx| opt.to_query(idx) }
        .join("&"),
      ].reject(&:empty?)
      .join("&")
    end
  end
end
