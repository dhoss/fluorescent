fluorescent
===========
[![Gem Version](https://badge.fury.io/rb/fluorescent.svg)](http://badge.fury.io/rb/fluorescent) [![Build Status](https://travis-ci.org/dhoss/fluorescent.svg?branch=master)](https://travis-ci.org/dhoss/fluorescent) [![Dependency Status](https://gemnasium.com/dhoss/fluorescent.svg)](https://gemnasium.com/dhoss/fluorescent)[![Code Climate](https://codeclimate.com/github/dhoss/fluorescent/badges/gpa.svg)](https://codeclimate.com/github/dhoss/fluorescent)

# Highlight search terms in a result set and distill the text surrounding the search terms.

Example:

   padding: 10

   search terms: "this is a test"

   search results: "what do you think this is a test"

   padded+highlighted display: "...t do you think **this is a test**..." 


## Basic example:

Here is a search method using [PgSearch](https://github.com/Casecommons/pg_search) to retrieve results in a Rails model:

```ruby
  def self.search(params)
    order_options =  params.has_key?('order_by')     ?
      { params['order_by'] => params['order_type'] } :
      { :published_on => 'desc'}
    results = with_author.published.fast_search(params['q'])
                         .page(params['page'])
                         .order(order_options)

     ## this is something I created to simply partition
     ## the formatted results and raw activerecord object collections
     Search::Result.new(
       :results   => results,
       :terms     => params['q'],
       :columns   => [:title,:body],
       :to_filter => [:body]
     )
  end
```

The Search::Result listing:

```ruby
  require 'fluorescent'
  module Search
    class Result
      attr_reader :formatter, :raw
      def initialize args
        @formatter = Fluorescent.new(args)
        @raw   = args[:results]
      end
    end
  end
```

An example controller:
```ruby
class SearchController < ApplicationController
  def index
    @results = []
    if params[:q]
      @results = Post.search(params.to_h)
      respond_to do |format|
        format.html { render action: "index" }
        format.json { render json: @results }
      end
    end
  end
end
```

And an example of how to display the results in a view:

```html+erb
<% if @results.formatter.formatted_results.any? && params[:q] %>
  <div class="search-results">
    <% @results.formatter.formatted_results.each do |r| %>
      <div class="blog-post">
        <div><%= link_to r[:title].html_safe, post_path(r[:id]) %></div>
        <div class="blog-post-meta">
          by <%= link_to r[:user][:name], r[:user].id %>
          on <%= r[:published_on] %>
        </div>
        <div class="blog-post-body">
          <%= r[:body].html_safe %>
        </div>
      </div>
      <hr />
    <% end %>
  </div>
  <% elsif !@results.formatter.formatted_results.any? && params[:q] %>
  <div class="search-result">
    (No results)
  </div>
<% end %>
```

License
=======
The MIT License (MIT)

Copyright (c) 2015 Devin Joel Austin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
