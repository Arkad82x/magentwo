require_relative '../lib/magentwo.rb'

describe Magentwo::Product do
  before(:all) do
    Magentwo.logger = Logger.new STDOUT, {:level => Logger::ERROR}
    @original_count = Magentwo::Product.count
  end

  context "#dataset" do
    let(:dataset) {Magentwo::Product.dataset}
    it "returns dataset" do
      expect(dataset).to be_a Magentwo::Dataset
    end
  end

  context "#count" do
    let(:count) {Magentwo::Product.count}
    it "responds to :count" do
      expect(Magentwo::Product).to respond_to :count
    end
    it "correct count" do
      expect(count).to eq @original_count
    end
    it "count is integer" do
      expect(count).to be_a Integer
    end
  end

  context "#all" do
    let(:products) {Magentwo::Product.all}
    let(:ds) {Magentwo::Product.dataset}

    it "responds to all" do
      expect(Magentwo::Product).to respond_to :all
    end
    it "returns an array" do
      expect(products).to be_a Array
    end
    it "requested all" do
      expect(products.count).to eq @original_count
    end
  end

  context "#fields" do
    let(:fields) {Magentwo::Product.fields}

    it "returns array of symbols" do
      expect(fields).to be_a Array
      fields.each do |field|
        expect(field).to be_a Symbol
      end
    end
  end

  context "#first" do
    let(:product) {Magentwo::Product.first}

    it "returns a product" do
      expect(product).to be_a Magentwo::Product
    end
  end

  context "#types" do
    let(:types) {Magentwo::Product.types}

    it "returns array" do
      expect(types).to be_a Array
    end
  end

  context "#[]" do
    let(:first_product) {Magentwo::Product.first}
    let(:by_sku_product) {Magentwo::Product[first_product.sku]}

    it "returns a product" do
      expect(by_sku_product).to be_a Magentwo::Product
    end

    it "returns product by :sku" do
      expect(first_product.sku).to eq by_sku_product.sku
    end
  end
end
