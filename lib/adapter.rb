module Magentwo
  class Adapter < Magentwo::Connection

    def call method, path, params
      http_method, params = case method
      when :put, :post, :delete then [method, params.to_json]
      when :get, :get_with_meta_data then [:get, params]
      else
        raise ArgumentError, "unknown method type. Expected :get, :get_with_meta_data, :post, :put or :delete. #{method} #{path}"
      end

      response = self.send(http_method, path, params)

      parsed_response = case method
      when :get_with_meta_data, :put, :post, :delete then parse response
      when :get
        parsed = parse(response)
        parsed[:items] ? parsed[:items] : parsed
      else
        raise ArgumentError, "unknown method type. Expected :get, :get_with_meta_data, :post, :put or :delete. #{method} #{path}"
      end
    end

    private
    def parse response
      case response.code
      when "200" then JSON.parse response.body, :symbolize_names => true
      else
        p "request failed #{response.code} #{response.body}"
      end
    end
  end
end
