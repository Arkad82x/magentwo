require 'uri'
require 'net/http'
require 'json'
require 'logger'

module Magentwo
  Models = %w(base product customer order coupon sales_rule)
  def self.connect host, user_name, password
    Base.adapter = Adapter.new host, user_name, password
  end

  def self.logger= logger
    @@logger = logger
  end

  def self.logger
    @@logger ||= Logger.new STDOUT, {:level => Logger::DEBUG}
  end

  def self.default_page_size
    @@default_page_size ||= 20
  end

  def self.default_page_size= page_size
    @@default_page_size = page_size
  end


end

require_relative 'connection.rb'
require_relative 'adapter.rb'
require_relative 'filter.rb'
require_relative 'dataset.rb'
require_relative 'util/validator.rb'

Magentwo::Models.each do |file_name|
	require_relative("model/#{file_name}.rb")
end
