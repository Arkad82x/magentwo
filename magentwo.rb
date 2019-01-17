require 'pry'
require_relative 'lib/magentwo.rb'

Magentwo.connect 'magento2.local',"admin","magentorocks1"

binding.pry
