require 'rubygems' 
require 'bundler/setup'
class Fluorescent
  attr_accessor :columns, :to_filter, :results, :terms, :padding, :formatted_results
  def initialize args
    # number of characters to display before/after search terms
    # example:
    # padding: 10
    # search terms: "this is a test"
    # search results: "what do you think this is a test"
    # padded display: "...t do you think this is a test..." 
    @padding           = 10
    @formatted_results = []
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  # distill search result down to n characters before and after
  # search terms
  def distill
    @results.each do |r|
      row = {}
      @columns.each do |c|
        # 1. highlight the search terms
        # 2. replace the search terms in the results with bold text
        #    index starting at the first character of the search terms
        #    to the length of the search terms + the padding config value
      string = r.send(c).to_s
        row[c] = highlight string # need to find a better way to do this
        if @to_filter.include? c
          row[c]   = highlight string[
            string.index(@terms[0]), 
            string.index(@terms[0]) + @terms.length + @padding
          ] << "..."
        end
      end
      @formatted_results.push({:id =>r.id}.merge(row))
    end
  end

  # highlight the search terms in the result
  def highlight(string)
    string.gsub @terms, "<b>#{@terms}</b>"
  end

  def formatted_results
    distill
    @formatted_results
  end

end
