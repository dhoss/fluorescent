fluorescent
===========
[![Gem Version](https://badge.fury.io/rb/fluorescent.svg)](http://badge.fury.io/rb/fluorescent) [![Build Status](https://travis-ci.org/dhoss/fluorescent.svg?branch=master)](https://travis-ci.org/dhoss/fluorescent) [![Dependency Status](https://gemnasium.com/dhoss/fluorescent.svg)](https://gemnasium.com/dhoss/fluorescent)

Summary
=======
Highlight search terms in a result set and distill the text surrounding the search terms.

Install
=======


  gem install fluorescent

Synopsis
========

Rails:
------

Inside your search model:
-------------------------
```ruby
  # Perform a search on something
  # I used ActiveRecord + PgSearch

  class Post < ActiveRecord::Base

  require 'fluorescent'

  def self.search(params)
    # search results provided by you
    Fluorescent.new(
      :results   => Search.find(params),
      :terms     => params,
      :columns   => [:title, :author, :body]
      :to_filter => [:body]
    )
  end 
```

Controller
----------
```ruby
  def index
    @results = []
    if params[:q]
      @results = Post.search(params[:q])
      respond_to do |format|
        format.html ...
        format.json ...
      end
    end
  end
```
View:
-----
```erb

  <h1>Search posts</h1>
  <%= form_tag("/search", method: "get") do %>
    <%= label_tag(:q, "Search for:") %>
    <%= text_field_tag(:q) %>
    <%= submit_tag("Search") %>
  <% end %>

  <% if @results.any? && params[:q] %>
    <div id="search-result-header">Search results:</div>
    <% @results.each do |r| %>
      <div class="search-result">
        <div class="search-result-link">
          <%= link_to r[:title].html_safe, post_path(r[:id]) %>
        </div>
        <div class="search-result-body">
          <%= r[:body].html_safe %>
        </div>

      </div>
    <% end %>
  <% elsif !@results.any? && params[:q] %>
    <div class="search-result">
      (No results)
    </div>
  <% end %>
```
  
