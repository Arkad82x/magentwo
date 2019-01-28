require 'uri'
require 'net/http'
require 'json'
require 'logger'

module Magentwo
  Models = %w(base product customer order coupon sales_rule)
  def self.connect host, user_name, password
    Base.connection = Connection.new host, user_name, password
  end

  def self.logger= logger
    @@logger = logger
  end

  def self.logger
    @@logger ||= Logger.new STDOUT, {:level => Logger::DEBUG}
  end
end

require_relative 'connection.rb'
require_relative 'filter.rb'
require_relative 'dataset.rb'
Magentwo::Models.each do |file_name|
	require_relative("model/#{file_name}.rb")
end
