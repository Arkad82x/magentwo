require 'uri'
require 'net/http'
require 'json'

module Magentwo
  Models = %w(product customer order)
end


require_relative 'connection.rb'
require_relative 'model/base.rb'
require_relative 'filter.rb'
require_relative 'dataset.rb'
Magentwo::Models.each do |file_name|
	require_relative("model/#{file_name}.rb")
end
