module Magentwo
  class Connection
    attr_accessor :host, :port, :user, :password, :token, :base_path

    def initialize uri, user, password, base_path:nil
      uri = URI(uri)
      @host = uri.host
      @port = uri.port
      @user = user
      @password = password
      @base_path = base_path || "/rest/V1"
      request_token
    end

    def request_token
      Net::HTTP.start(self.host,self.port) do |http|
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

    def delete path, data
      Magentwo.logger.info "DELETE #{host}/#{base_path}/#{path}"
      Magentwo.logger.debug "DATA #{data}"

      url = "#{base_path}/#{path}"
      Net::HTTP.start(self.host,self.port) do |http|
        req = Net::HTTP::Delete.new(url)
        req["Authorization"] = "Bearer #{self.token}"
        req['Content-Type'] = "application/json"
        req.body = data
        http.request(req)
      end
    end

    def put path, data
      Magentwo.logger.info "PUT #{host}/#{base_path}/#{path}"
      Magentwo.logger.debug "DATA #{data}"
      url = "#{base_path}/#{path}"
      Net::HTTP.start(self.host,self.port) do |http|
        req = Net::HTTP::Put.new(url)
        req["Authorization"] = "Bearer #{self.token}"
        req['Content-Type'] = "application/json"
        req.body = data
        http.request(req)
      end
    end

    def post path, data
      Magentwo.logger.info "POST #{host}/#{path}"
      Magentwo.logger.debug "DATA #{data}"
      url = "#{base_path}/#{path}"
      Net::HTTP.start(self.host,self.port) do |http|
        req = Net::HTTP::Post.new(url)
        req["Authorization"] = "Bearer #{self.token}"
        req['Content-Type'] = "application/json"
        req.body = data
        http.request(req)
      end
    end


    def get path, query
      Magentwo.logger.info "GET #{host}#{base_path}/#{path}?#{query}"
      url = "#{base_path}/#{path}?#{query}"
      Net::HTTP.start(self.host,self.port) do |http|
        req = Net::HTTP::Get.new(url)
        req["Authorization"] = "Bearer #{self.token}"
        req['Content-Type'] = "application/json"
        http.request(req)
      end
    end
  end
end
