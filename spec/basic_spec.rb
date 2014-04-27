require "minitest/autorun"
require "fluorescent"
require_relative './mock/results'

describe Fluorescent do
  before do
    @columns = [:title, :body]
    @to_filter = [:body]
    @search_terms = "toot"
    @results = [
      Results.new(
        :id    => "1234",
        :name  => "fart",
        :title => "farty mcfart",
        :body  => "huehuehtootuehuehuehue"
      ),
      Results.new(
        :id    => "123",
        :name  => "toot",
        :title => "tooty mctoot",
        :body  => "pffffft"
      )
    ]
    @highlighter = Fluorescent.new(
      :results   => @results,
      :terms     => @search_terms,
      :columns   => @columns,
      :to_filter => @to_filter
    )
  end

  describe "when initialized" do
    it "will have results, terms, columns and to_filter set" do
      ["results", "terms", "columns", "to_filter"].each do |p|
        @highlighter.send(p).wont_be_nil
      end
    end
  end

  describe "when highlight is passed a string" do
    it "will highlight the search terms" do
      @highlighter.highlight("we are looking for the string toot")
                  .must_equal("we are looking for the string <b>toot</b>")
    end
  end

  describe "when we call formatted_results" do
    it "will highlight and pare down the string" do
      terms = @highlighter.terms
      @highlighter.formatted_results.each do |r|
        @to_filter.each do |filter|
          r[filter].must_match /<b>\w+<\/b>/
        end
      end
    end
  end
end
