require 'benchmark'
require 'faker'
require_relative '../lib/fluorescent.rb'
require_relative '../spec/mock/results'

little_red_corvette = IO.read(File.expand_path "./benchmarking/lrc.txt")
mocked_result = Results.new(
        :id    => "1234",
        :name  => "Prince",
        :title => "Little Red Corvette",
        :body  => little_red_corvette
      )

puts "Benchmarking object creation"
puts Benchmark.measure {
  # benchmark creating an object
  1000.times do
    f = Fluorescent.new(
      :results   => mocked_result,
      :terms     => "little red corvette",
      :columns   => [:title, :name, :body],
      :to_filter => [:body]
    )
  end
}

puts "Benchmarking highlighting"
puts Benchmark.measure {
  # benchmark highlighting a large string
  1000.times do
    f = Fluorescent.new(
      :results   => mocked_result,
      :terms     => "little red corvette",
      :columns   => [:title, :name, :body],
      :to_filter => [:body]
    )
    f.highlight(mocked_result.body)
  end
}

puts "Benchmarking formatted_results"
puts Benchmark.measure {
  # benchmark formatted_results with large string
  1000.times do
    f = Fluorescent.new(
      :results   => [mocked_result],
      :terms     => "little red corvette",
      :columns   => [:title, :name, :body],
      :to_filter => [:body]
    )
    f.formatted_results
  end
}
