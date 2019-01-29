module Magentwo
  class Connection
    attr_accessor :host, :port, :user, :password, :token, :base_path

    def initialize host, user, password, base_path:nil
      if host.include? ":"
        @host = host.split(":").first
        @port = host.split(":").last.to_i
      else
        @host = host
        @port = 80
      end
      @user = user
      @password = password
      @base_path = base_path || "/rest/default/V1"
      request_token
    end

    def request_token
      Net::HTTP.start(self.host,self.port) do |http|
        req = Net::HTTP::Post.new("#{base_path}/integration/admin/token")
        req.body = {:username=> self.user, :password=> self.password}.to_json
        req['Content-Type'] = "application/json"
        req['Content-Length'] = req.body.length
        @token = JSON.parse http.request(req).body
      end
    end

    def delete path, data
      Magentwo.logger.info "DELETE #{path}"
      Magentwo.logger.debug "DATA #{data}"

      Magentwo.logger.warn "not implemented"

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
        resp = http.request(req)
        handle_response resp
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
        req.body = data.to_json
        resp = http.request(req)
        handle_response resp
      end
    end


    def get_with_meta_data path, query
      Magentwo.logger.info "GET #{host}#{base_path}/#{path}?#{query}"
      url = "#{base_path}/#{path}?#{query}"
      Net::HTTP.start(self.host,self.port) do |http|
        req = Net::HTTP::Get.new(url)
        req["Authorization"] = "Bearer #{self.token}"
        req['Content-Type'] = "application/json"
        resp = http.request(req)
        handle_response resp
      end
    end

    def get path, query
      response = get_with_meta_data(path, query)
      return response unless response[:items]
      return response[:items]
    end

    private
    def handle_response response
      case response.code
      when "200" then JSON.parse response.body, :symbolize_names => true
      else
        raise "request failed #{response.code} #{response.body}"
      end
    end
  end
end
