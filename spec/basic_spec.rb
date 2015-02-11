require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require "minitest/autorun"
require "fluorescent"
require_relative './mock/results'
require 'pp'


describe Fluorescent do
  before do
    @columns = [:title, :body]
    @to_filter = [:body]
    @search_terms = "toot"
    @padding = 100
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
        :body  => "pffffft toot fart proot"
      )
    ]

    @results2 = [
      Results.new(
        :id    => "1234",
        :name  => "fart",
        :title => "farty mcfart",
        :body  => "the word you are searching for doesn't exist here"
      )
    ]

    

    @highlighter = Fluorescent.new(
      :results   => @results,
      :terms     => @search_terms,
      :columns   => @columns,
      :to_filter => @to_filter,
      :padding   => @padding
    )
    
    @highlighter2 = Fluorescent.new(
      :results   => @results2,
      :terms     => @search_terms,
      :columns   => @columns,
      :to_filter => @to_filter,
      :padding   => @padding
    )


    @long_text = %q{Treeify, and (right now) it just gives us a little wrapper around some recursive SQL queries.  Here's the main method we are concerned with:
def tree_sql(instance)
  "WITH RECURSIVE cte (id, path) AS (
     SELECT id,
       array[id] AS path
     FROM #{table_name}
     WHERE id = #{instance.id}
     UNION ALL
     SELECT #{table_name}.id,
            cte.path || #{table_name}.id
     FROM #{table_name}
     JOIN cte ON #{table_name}.parent_id = cte.id
    )"
 end
 

This generates some SQL that ends up looking like this:

SELECT "posts".* FROM "posts" WHERE (posts.id IN (WITH RECURSIVE cte (id, path) AS (
 SELECT id,
 array[id] AS path
 FROM posts
 WHERE id = 7
UNION ALL
SELECT posts.id,
 cte.path || posts.id
 FROM posts
 JOIN cte ON posts.parent_id = cte.id
 )
 SELECT id FROM cte
 ORDER BY path)) ORDER BY posts.id
This does alright performance-wise, although I'd much rather not have the "IN" portion there and have it do a JOIN or something instead, as I believe that would be faster, but I digress.

So, moving on, we have a method called "descendents" which basically grabs all the desecendents for a given post:

def descendents
  self_and_descendents - [self]
end
self_and_descendents simply grabs the whole tree, descendents just removes the root of the tree.  This gives us our tree of descendents, which ends up looking something like this (after a little bit of serialization - we'll get to that):

[{"id"=>20,
 "title"=>"RE: testing",
 "body"=>"<p>asfsafasd</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "updated_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'asfsafasd':3 're':1 'test':2",
 "slug"=>"re-testing"},
 {"id"=>21,
 "title"=>"RE: testing",
 "body"=>"<p>poop</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'poop':3 're':1 'test':2",
 "slug"=>"re-testing-4d35d96b-1c8b-4749-bf4b-052af7baf3cf"},
 {"id"=>22,
 "title"=>"RE: RE: testing",
 "body"=>"<p>poop fart</p>",
 "parent_id"=>21,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':5 'poop':4 're':1,2 'test':3",
 "slug"=>"re-re-testing"},
 {"id"=>23,
 "title"=>"RE: RE: RE: testing",
 "body"=>"<p>poop and fart</p>",
 "parent_id"=>22,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':7 'poop':5 're':1,2,3 'test':4",
 "slug"=>"re-re-re-testing"}]
Cool!  Our whole tree in one query.

But, it's not a tree, it's just a hash.  We need a tree or it will look really weird when we display it.  Let's fix that.

Let's create a method in our model called "build_tree".  We can pass it our results from our descendents method, which I do like so:

 def reply_tree
   # give build_tree an array of hashes with 
   # the AR objects serialized into a hash
   build_tree(descendents.to_a.map(&:serializable_hash))
 end 
This just turns our descendents data into a serializable hash, which could be turned into JSON, or mangled more easily, like so:

 

def build_tree(data)
  # turn our AoH into a hash where we've mapped the ID column
  # to the rest of the hash + a comments array for nested comments
  nested_hash = Hash[data.map{|e| [e['id'], e.merge('comments' => [])]}]
  # if we have a parent ID, grab all the comments
  # associated with that parent and push them into the comments array
  nested_hash.each do |id, item|
    nested_hash[id]['name'] = item['user_id'] ? User.find(item['user_id']).name : "Anonymous"
    parent = nested_hash[item['parent_id']]
    parent['comments'] << item if parent
  end
   # return the values of our nested hash, ie our actual comment hash data
   # reject any descendents whose parent ID already exists in the main hash so we don't
   # get orphaned descendents listed as their own comment
   nested_hash.reject{|id, item|
     nested_hash.has_key? item['parent_id']
   }.values
 end
Let's walk through this a little bit.

First, we want to turn our array of hashes into a nested hash, since we are dealing with tree data.

nested_hash = Hash[data.map{|e| [e['id'], e.merge('comments' => [])]}]

This casts the data variable (our array of hashes) as a hash, and maps each id to a the original hash (the comment data itself), and merges in a new key called "comments" that's assigned to an empty array.  This sets us up for our nested comments.

At this point, our data structure looks like this: 

{20=>
 {"id"=>20,
 "title"=>"RE: testing",
 "body"=>"<p>asfsafasd</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "updated_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'asfsafasd':3 're':1 'test':2",
 "slug"=>"re-testing",
 "comments"=>[]},
 21=>
 {"id"=>21,
 "title"=>"RE: testing",
 "body"=>"<p>poop</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'poop':3 're':1 'test':2",
 "slug"=>"re-testing-4d35d96b-1c8b-4749-bf4b-052af7baf3cf",
 "comments"=>[]},
 22=>
 {"id"=>22,
 "title"=>"RE: RE: testing",
 "body"=>"<p>poop fart</p>",
 "parent_id"=>21,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':5 'poop':4 're':1,2 'test':3",
 "slug"=>"re-re-testing",
 "comments"=>[]},
 23=>
 {"id"=>23,
 "title"=>"RE: RE: RE: testing",
 "body"=>"<p>poop and fart</p>",
 "parent_id"=>22,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':7 'poop':5 're':1,2,3 'test':4",
 "slug"=>"re-re-re-testing",
 "comments"=>[]}}
As you can see like I mentioned earlier, we have a hash with each comment's ID as the key and the value is the actual comment data.

Next step, we want to load up the sub-comments.

 nested_hash.each do |id, item|
   nested_hash[id]['name'] = item['user_id'] ? User.find(item['user_id']).name : "Anonymous"
   parent = nested_hash[item['parent_id']]
   parent['comments'] << item if parent
 end
This basically traverses the current hash and checks to see if the current node has a parent ID that matches an ID in the hash, and pushes that data into the 'comments' array.

This is what it ends up looking like:

{20=>
 {"id"=>20,
 "title"=>"RE: testing",
 "body"=>"<p>asfsafasd</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "updated_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'asfsafasd':3 're':1 'test':2",
 "slug"=>"re-testing",
 "comments"=>[],
 "name"=>"Devin"},
 21=>
 {"id"=>21,
 "title"=>"RE: testing",
 "body"=>"<p>poop</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'poop':3 're':1 'test':2",
 "slug"=>"re-testing-4d35d96b-1c8b-4749-bf4b-052af7baf3cf",
 "comments"=>
 [{"id"=>22,
 "title"=>"RE: RE: testing",
 "body"=>"<p>poop fart</p>",
 "parent_id"=>21,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':5 'poop':4 're':1,2 'test':3",
 "slug"=>"re-re-testing",
 "comments"=>
 [{"id"=>23,
 "title"=>"RE: RE: RE: testing",
 "body"=>"<p>poop and fart</p>",
 "parent_id"=>22,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':7 'poop':5 're':1,2,3 'test':4",
 "slug"=>"re-re-re-testing",
 "comments"=>[],
 "name"=>"Devin"}],
 "name"=>"Devin"}],
 "name"=>"Devin"},
 22=>
 {"id"=>22,
 "title"=>"RE: RE: testing",
 "body"=>"<p>poop fart</p>",
 "parent_id"=>21,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':5 'poop':4 're':1,2 'test':3",
 "slug"=>"re-re-testing",
 "comments"=>
 [{"id"=>23,
 "title"=>"RE: RE: RE: testing",
 "body"=>"<p>poop and fart</p>",
 "parent_id"=>22,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':7 'poop':5 're':1,2,3 'test':4",
 "slug"=>"re-re-re-testing",
 "comments"=>[],
 "name"=>"Devin"}],
 "name"=>"Devin"},
 23=>
 {"id"=>23,
 "title"=>"RE: RE: RE: testing",
 "body"=>"<p>poop and fart</p>",
 "parent_id"=>22,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':7 'poop':5 're':1,2,3 'test':4",
 "slug"=>"re-re-re-testing",
 "comments"=>[],
 "name"=>"Devin"}}
 

We now have populated sub-comments.

The final step is to make sure sub-comments are only displayed in their respective array.

nested_hash.reject{|id, item| 
  nested_hash.has_key? item['parent_id']
}.values
Iterate over the hash, rejecting anything that has a parent_id that exists in the top-most level of the hash, and return the values of the "good" keys.

Giving us:

[{"id"=>20,
 "title"=>"RE: testing",
 "body"=>"<p>asfsafasd</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "updated_at"=>Thu, 02 Oct 2014 20:04:45 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'asfsafasd':3 're':1 'test':2",
 "slug"=>"re-testing",
 "comments"=>[],
 "name"=>"Devin"},
 {"id"=>21,
 "title"=>"RE: testing",
 "body"=>"<p>poop</p>",
 "parent_id"=>7,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:17 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'poop':3 're':1 'test':2",
 "slug"=>"re-testing-4d35d96b-1c8b-4749-bf4b-052af7baf3cf",
 "comments"=>
 [{"id"=>22,
 "title"=>"RE: RE: testing",
 "body"=>"<p>poop fart</p>",
 "parent_id"=>21,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:28 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':5 'poop':4 're':1,2 'test':3",
 "slug"=>"re-re-testing",
 "comments"=>
 [{"id"=>23,
 "title"=>"RE: RE: RE: testing",
 "body"=>"<p>poop and fart</p>",
 "parent_id"=>22,
 "user_id"=>1,
 "created_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "updated_at"=>Fri, 03 Oct 2014 02:01:40 UTC +00:00,
 "category_id"=>1,
 "tsv"=>"'fart':7 'poop':5 're':1,2,3 'test':4",
 "slug"=>"re-re-re-testing",
 "comments"=>[],
 "name"=>"Devin"}],
 "name"=>"Devin"}],
 "name"=>"Devin"}]
...a nice tree-like structure we can iterate over in whatever we choose for a view.  Disregard the extra "name"=>".." bits, I'm still working out how to best retrieve author data and am currently using a hacky and ugly method to do so.

 

That's all for now.  Hopefully this sheds some light on this sort of thing.  Some improvements right off the bat would be to put the nested tree construction in the treeify gem, and to make the SQL less clunky so we can mold it a little more, and get associated data easier (like author info). 
    }

    @results3 = [
      Results.new(
        :id    => "1234",
        :name  => "fart",
        :title => "long ass damn text in the body",
        :body  => @long_text
      )
    ]

    @highlighter3 = Fluorescent.new(
      :results   => @results3,
      :terms     => @search_terms,
      :columns   => @columns,
      :to_filter => @to_filter,
      :padding   => @padding
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

  describe "when we filter results" do
    it "matches the original column names" do
      [:id,:name,:title,:body].each do |c|
        @highlighter.formatted_results.each do |r|
          r.has_key?(c).must_equal true
        end
      end
    end

    it "ensures we don't die if nothing matches" do
      @highlighter2.formatted_results.each do |r|
        assert r[:body].length <= @results2[0].body.length + 1 + @search_terms.length + @padding + 7 + 3
      end
    end

    it "truncates text properly" do
      @highlighter3.formatted_results.each do |r|
        @results3.each do |raw|
          expected_length = 1         + @search_terms.length + @padding + 7    + 3
                            #1st char                                    <b..>   ...
          expected_length += @highlighter.highlight(raw.body).length

          assert r[:body].length <= expected_length,
            ":body (#{r[:body]}) length (#{r[:body].length}) <= #{expected_length}"
        end
      end
    end
  end

end
