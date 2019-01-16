module Magentwo
  class Dataset
    attr_accessor :model, :opts
    def initialize model, opts
      self.model = model
      self.opts = opts || []
    end

    def filter args, invert=false
      filter = case args
      when Hash
        case args.values.first
        when Array
          unless invert
            Filter::In.new(args.keys.first, args.values.first)
          else
            Filter::Nin.new(args.keys.first, args.values.first)
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
      filter args, true
    end

    def all
      self.model.call :get, self.to_query
    end

    def to_query
      return "searchCriteria=" if self.opts.empty?

      self.opts
      .each_with_index
      .map { |opt, idx| opt.to_query(idx) }
      .join("&")
    end
  end
end
