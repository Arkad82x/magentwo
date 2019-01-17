require_relative '../lib/magentwo.rb'

describe 'product' do
  Magentwo::Base.connection = Magentwo::Connection.new('magento2.local',"admin","magentorocks1")
  it 'returns an array when list is called' do
    expect(Magentwo::Product.list.class).to eq Array
  end
end
