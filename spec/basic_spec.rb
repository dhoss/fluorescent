require "minitest/autorun"
require "fluorescent"

describe Fluorescent do
  before do
    @results = [
      {
        :name  => "fart",
        :title => "farty mcfart",
        :body  => "huehuehuehuehuehue"
      },
      {
        :name  => "toot",
        :title => "tooty mctoot",
        :body  => "pffffft"
      }
    ]

    @highlighter = Fluorescent.new(
      :results   => @results,
      :terms     => "toot",
      :columns   => [:title, :body],
      :to_filter => :body
    )
  end

  describe "when initialized" do
    it "will have results, terms, columns and to_filter set" do
      ["results", "terms", "columns", "to_filter"].each do |p|
        @highlighter.send(p).wont_be_nil
      end
    end
  end
end
