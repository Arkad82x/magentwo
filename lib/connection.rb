module Magentwo
  class Connection
    attr_accessor :host, :port, :user, :password, :token, :base_path, :scheme

    def initialize uri:, user:nil, password:nil, base_path:nil, token:nil
      uri = URI(uri)
      @host = uri.host
      @port = uri.port
      @scheme = uri.scheme
      @base_path = base_path || "/rest/V1"

      if (user && password)
        @user = user
        @password = password
        request_token
      elsif (token)
        @token = token
      else
        raise ArgumentError, "expected user/password or token"
      end

    end

    def request_token
      Net::HTTP.start(self.host,self.port, :use_ssl => self.scheme == 'https') do |http|
        url = "#{base_path}/integration/admin/token"
        Magentwo.logger.info "POST #{url}"
        req = Net::HTTP::Post.new(url)
        req.body = {:username=> self.user, :password=> self.password}.to_json
        req['Content-Type'] = "application/json"
        req['Content-Length'] = req.body.length
        response = http.request(req).body
        @token = JSON.parse response
      end
    end

    def request verb, path:, data:nil
      Magentwo.logger.info "#{verb.to_s} #{host}/#{base_path}/#{path}"
      Magentwo.logger.debug "DATA #{data}"

      url = "#{base_path}/#{path}"
      Net::HTTP.start(self.host,self.port, :use_ssl => self.scheme == 'https') do |http|
        req = verb.new(url)
        req["Authorization"] = "Bearer #{self.token}"
        req['Content-Type'] = "application/json"
        req.body = data
        http.request(req)
      end
    end

    def delete path, data
      request Net::HTTP::Delete, path:path, data:data
    end

    def put path, data
      request Net::HTTP::Put, path:path, data:data
    end

    def post path, data
      request Net::HTTP::Post, path:path, data:data
    end

    def get path, query
      request Net::HTTP::Get, path:"#{path}?#{query}"
    end
  end
end
