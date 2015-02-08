fluorescent
===========
[![Gem Version](https://badge.fury.io/rb/fluorescent.svg)](http://badge.fury.io/rb/fluorescent) [![Build Status](https://travis-ci.org/dhoss/fluorescent.svg?branch=master)](https://travis-ci.org/dhoss/fluorescent) [![Dependency Status](https://gemnasium.com/dhoss/fluorescent.svg)](https://gemnasium.com/dhoss/fluorescent)

# Highlight search terms in a result set and distill the text surrounding the search terms.

Example:

   padding: 10

   search terms: "this is a test"

   search results: "what do you think this is a test"

   padded display: "...t do you think this is a test..." 


## Basic example:

Here is a search method using [PgSearch](https://github.com/Casecommons/pg_search) to retrieve results in a Rails model:

```
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

```
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
```
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

```
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

 
