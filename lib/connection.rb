module Magentwo
  class Connection
    attr_accessor :host, :user, :password, :token, :base_path

    def initialize host, user, password, base_path:nil
      @host = host
      @user = user
      @password = password
      @base_path = base_path || "/rest/default/V1"
      request_token
    end

    def request_token
      Net::HTTP.start(self.host,80) do |http|
        req = Net::HTTP::Post.new("#{base_path}/integration/admin/token")
        req.body = {:username=> self.user, :password=> self.password}.to_json
        req['Content-Type'] = "application/json"
        req['Content-Length'] = req.body.length
        @token = JSON.parse http.request(req).body
      end
    end

    def call method, path, query
      url = "#{base_path}/#{path}?#{query}"
      case method
      when :get then self.get url
      when :post then self.post url
      when :delete then self.delete url
      when :put then self.put url
      else
        raise "unknown http method, cannot call #{method}, expected :get, :post, :delete or :put"
      end
    end

    def delete

    end

    def put

    end

    def post

    end

    def get url
      p "get: #{url}"
      Net::HTTP.start(host,80) do |http|
        req = Net::HTTP::Get.new(url)
        req["Authorization"] = "Bearer #{self.token}"
        req['Content-Type'] = "application/json"
        resp = http.request(req)
        handle_response resp
      end
    end

    private
    def handle_response response
      case response.code
      when "200" then JSON.parse response.body
      else
        raise "request failed #{response.code} #{response.body}"
      end
    end
  end
end
