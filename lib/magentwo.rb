require 'net/http'
require 'json'

module Magentwo
  class Request
    def initialize
    end
  end

  class Client
    attr_accessor :host, :user, :password, :token

    def initialize host, user, password
      @host = host
      @user = user
      @password = password
      p request_token
    end

    def request_token
      Net::HTTP.start(host,80) do |http|
        req = Net::HTTP::Post.new("/index.php/rest/V1/integration/admin/token")
        req.body = {:username=> user, :password=> password}.to_json
        req['Content-Type'] = "application/json"
        req['Content-Length'] = req.body.length
        @token = JSON.parse http.request(req).body
      end
    end

  end
end

#Magentwo::Client.new('magento2',"admin","magentorocks")
