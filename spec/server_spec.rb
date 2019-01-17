require_relative '../lib/model/base.rb'

describe 'setup' do
  before do
    Magentwo::Base.connection = Magentwo::Connection.new('magento2.local',"admin","magentorocks1")
  end
end
