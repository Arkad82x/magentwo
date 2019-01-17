module Magentwo
  class Dataset
    attr_accessor :model, :opts
    def initialize model, opts
      self.model = model
      self.opts = opts || []
    end

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
      Dataset.new self.model, self.opts + [filter]
    end

    def exclude args
      filter args, invert:true
    end

    def select *fields
      Dataset.new self.model, self.opts + [Filter::Fields.new(fields)]
    end

    def fields
      self.first["items"].first.keys
    end

    def info
      first = self.first
      {
        :fields => first["items"].first.keys,
        :total_count => first["total_count"]
      }
    end

    def first
      self.page(1, 1).all
    end

    def count
      self.first["total_count"]
    end

    def page page, page_size=20
      Dataset.new self.model, self.opts + [Filter::PageSize.new(page_size), Filter::CurrentPage.new(page)]
    end

    def order_by field, direction="ASC"
      Dataset.new self.model, self.opts + [Filter::OrderBy.new(field, direction)]
    end

    def like args
      Dataset.new self.model, self.opts + [Filter::Like.new(args.keys.first, args.values.first)]
    end

    def fields
      self.first&.keys
    end

    def all
      self.model.call :get, self.to_query
    end

    def to_query
      #TODO this is a hack because api required searchCriteria to be set, so Magentwo::Product.all would lead to an error
      return "searchCriteria=" if self.opts.empty?

      self.opts
      .each_with_index
      .map { |opt, idx| opt.to_query(idx) }
      .join("&")
    end
  end
end
