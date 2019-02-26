module Magentwo
  class Dataset
    attr_accessor :model, :opts
    def initialize model, opts=nil
      self.model = model
      self.opts = opts || {
        :filters => [],
        :pagination => {
          :current_page => Filter::CurrentPage.new(1),
          :page_size => Filter::PageSize.new(0)
        },
        :ordering => [],
        :fields => nil
      }
    end

    #################
    # Filters
    ################
    def filter hash_or_other, invert:false
      filters = case hash_or_other
      when Hash
        raise ArgumentError, "empty hash supplied" if hash_or_other.empty?
        hash_or_other.map do |key, value|
          klass = case value
          when Array
            invert ? Filter::Nin : Filter::In
          else
            invert ? Filter::Neq : Filter::Eq
          end
          klass.new(key, value)
        end
      else
        raise ArgumentError, "filter function expects Hash as input"
      end
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + filters)
    end

    def exclude args
      filter args, invert:true
    end

    def gt args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::Gt.new(args.keys.first, args.values.first)])
    end

    def lt args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::Lt.new(args.keys.first, args.values.first)])
    end

    def gteq args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::Gteq.new(args.keys.first, args.values.first)])
    end

    def lteq args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::Lteq.new(args.keys.first, args.values.first)])
    end

    def select *fields
      Dataset.new self.model, self.opts.merge(:fields => Filter::Fields.new(fields))
    end

    def like args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::Like.new(args.keys.first, args.values.first)])
    end

    def from args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::From.new(args.keys.first, args.values.first)])
    end

    def to args
      Dataset.new self.model, self.opts.merge(:filters => self.opts[:filters] + [Filter::To.new(args.keys.first, args.values.first)])
    end

    #################
    # Pagination
    ################
    def page page, page_size=Magentwo.default_page_size
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
      result = self.model.get self.page(1, 1).to_query, {:meta_data => true}
      {
        :fields => result[:items]&.first&.keys,
        :total_count => result[:total_count]
      }
    end

    def count
      self.info[:total_count]
    end

    def fields
      self.info[:fields]
    end

    def first
      self.model.first self
    end

    def all
      self.model.all self
    end

    #################
    # Transformation
    ################
    def print_readable
      ds = self

      puts "*** Pagination ***"
      puts ds.opts[:pagination][:current_page].to_s
      puts ds.opts[:pagination][:page_size].to_s

      puts "*** Filters ***"
      ds.opts[:filters].each do |filter|
        puts filter.to_s
      end

      puts "*** Ordering ***"
      order_filters = ds.opts[:ordering]
      if order_filters.size > 0
        order_filters.each do |filter|
          puts filter.to_s
        end
      else
        puts "non specified"
      end

      puts "*** Fields ***"
      if fields = ds.opts[:fields]&.fields
        puts "Fetch only: #{fields}"
      else
        puts "Fetch everything"
      end
    end

    def to_query
      self.validate
      [
        ds.opts[:filters]
        .each_with_index
        .map { |opt, idx| opt.to_query(idx) }
        .join("&"),

        ds.opts[:pagination]
        .map { |k, v| v.to_query}
        .join("&"),


        ds.opts[:ordering]
        .map { |opt, idx| opt.to_query(idx) }
        .join("&"),

        ds.opts[:fields]? ds.opts[:fields].to_query() : ""
      ].reject(&:empty?)
      .join("&")
    end

    #################
    # Functors
    ################
    def map(&block)
      raise ArgumentError, "no block given" unless block_given?
      self.model.all.map(&block)
    end

    def each(&block)
      raise ArgumentError, "no block given" unless block_given?
      self.model.all.each(&block)
    end

    def each_page page_size=Magentwo.default_page_size, &block
      raise ArgumentError, "no block given" unless block_given?

      received_element_count = page_size
      current_page = 1
      while(received_element_count == page_size) do
        page = self.page(current_page, page_size).all

        block.call(page)

        received_element_count = page.count
        current_page += 1
      end
    end

    #################
    # Validation
    ################
    def validate
      true
    end
  end
end
