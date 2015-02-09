require 'rubygems' 
require 'bundler/setup'
class Fluorescent
  attr_accessor :columns, :to_filter, :results, :terms, :padding, :formatted_results, :id_column
  def initialize args
    # number of characters to display before/after search terms
    # example:
    # padding: 10
    # search terms: "this is a test"
    # search results: "what do you think this is a test"
    # padded display: "...t do you think this is a test..." 
    @padding           = 10
    @formatted_results = []
    @id_column = "id"
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def column_names_to_h r
    row = {}
    # make sure we get the rest of the column names in the hash
    r.class.column_names.each do |c|
      row[c] = r.send(c)
    end
    row
  end

  # distill search result down to n characters before and after
  # search terms
  def distill
    @results.each do |r|
      row = column_names_to_h(r)
      
      @columns.each do |c|
        # 1. highlight the search terms
        # 2. replace the search terms in the results with bold text
        #    index starting at the first character of the search terms
        #    to the length of the search terms + the padding config value
        string = r.send(c).to_s
        row[c] = highlight string # need to find a better way to do this
        if @to_filter.include? c
          # if nothing matches, we don't want to try to highlight
          if string.index(@terms[0]) != nil
            row[c]   = highlight string[
              string.index(@terms[0]), 
              string.index(@terms[0]) + string.length + @padding
            ] << "..."
          end
        end
      end

      # symbolize hash keys
      @formatted_results.push(symbolize_keys(row))
    end
  end

  def symbolize_keys row
    row.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
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
