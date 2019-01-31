require_relative '../lib/magentwo.rb'

describe Magentwo::Dataset do
  let(:dataset) {Magentwo::Dataset.new Magentwo::Product}
  context "Initial Dataset" do
    let(:initial_query) {dataset.to_query}
    it "has opts" do
      expect(dataset).to respond_to :opts
      expect(dataset.opts).to have_key :pagination
      expect(dataset.opts).to have_key :ordering
      expect(dataset.opts).to have_key :filters
    end
    it "has model" do
      expect(dataset).to respond_to :model
      expect(dataset.model).to eq Magentwo::Product
    end
    it "has default pagination" do
      expect(dataset.opts[:pagination]).to have_key :current_page
      expect(dataset.opts[:pagination]).to have_key :page_size
    end
    it "requests all items on default" do
      expect(initial_query).to include "searchCriteria[current_page]=1"
      expect(initial_query).to include "searchCriteria[page_size]=0"
    end
  end

  context "simple name filter" do
    let(:name_filter_ds) {dataset.filter({:name => "foobar"})}
    let(:name_filter_query) {name_filter_ds.to_query}
    it "adds filter" do
      expect(name_filter_ds.opts[:filters]).to include Magentwo::Filter::Eq
    end
    it "computes query" do
      expect(name_filter_query).to include "searchCriteria[filter_groups][0][filters][0][field]=name"
      expect(name_filter_query).to include "searchCriteria[filter_groups][0][filters][0][condition_type]=eq"
      expect(name_filter_query).to include "searchCriteria[filter_groups][0][filters][0][value]=foobar"
    end
  end

  context "multi filter" do
    let(:multi_filter_ds) {dataset.filter(:name => "foobar").filter(:id => 42)}
    let(:multi_filter_query) {multi_filter_ds.to_query}
    let(:multi_filter_in_one_ds) {dataset.filter(:name => "foobar", :id => 42)}
    let(:multi_filter_in_one_query) {multi_filter_in_one_ds.to_query}
    it "contains filter with type Filter::Eq" do
      expect(multi_filter_ds.opts[:filters]).to include Magentwo::Filter::Eq
    end
    it "contains two filters" do
      expect(multi_filter_ds.opts[:filters].count).to eq 2
    end
    it "compute query" do
      expect(multi_filter_query).to include "searchCriteria[filter_groups][0][filters][0][field]=name"
      expect(multi_filter_query).to include "searchCriteria[filter_groups][0][filters][0][condition_type]=eq"
      expect(multi_filter_query).to include "searchCriteria[filter_groups][0][filters][0][value]=foobar"
      expect(multi_filter_query).to include "searchCriteria[filter_groups][1][filters][0][field]=id"
      expect(multi_filter_query).to include "searchCriteria[filter_groups][1][filters][0][condition_type]=eq"
      expect(multi_filter_query).to include "searchCriteria[filter_groups][1][filters][0][value]=42"
    end
    it "is the same for multiple keys in one filter" do
      expect(multi_filter_ds.opts.count).to eq multi_filter_in_one_ds.opts.count
      expect(multi_filter_query).to eq multi_filter_in_one_query
    end
  end

  context "select" do
    let(:name_select_ds) {dataset.select(:name)}
    let(:name_select_query) {name_select_ds.to_query}
    let(:multi_field_select_ds) {dataset.select(:field1, :field2)}
    let(:multi_field_select_query) {multi_field_select_ds.to_query}
    it "adds filter" do
      expect(name_select_ds.opts[:fields]).to be_an_instance_of Magentwo::Filter::Fields
    end
    it "computes name select query" do
      expect(name_select_query).to include "fields=items[name]"
    end
    it "adds multiple fields" do
      expect(multi_field_select_ds.opts).to have_key :fields
      expect(multi_field_select_ds.opts[:fields]).to be_an_instance_of Magentwo::Filter::Fields
      expect(multi_field_select_ds.opts[:fields].fields).to include :field1
      expect(multi_field_select_ds.opts[:fields].fields).to include :field2
    end
    it "computes multi select query" do
      expect(multi_field_select_query).to include "fields=items[field1,field2]"
    end
  end

  context "URL encoding" do
    let(:filter_query_with_spaces) {dataset.filter({:name => "Hello there, lets add some spaces here"}).to_query}
    it "encodes spaces" do
      expect(filter_query_with_spaces).to include "%20"
    end
  end
end
