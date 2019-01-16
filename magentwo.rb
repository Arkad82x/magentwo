require 'pry'
require_relative 'lib/magentwo.rb'

Magentwo::Base.connection = Magentwo::Connection.new('magento2.local',"admin","magentorocks1")

binding.pry
