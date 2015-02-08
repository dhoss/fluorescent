Gem::Specification.new do |s|
  s.name        = 'fluorescent'
  s.version     = '0.0.4'
  s.date        = '2015-02-08'
  s.summary     = "Highlight and distill search terms."
  s.description = "Highlight search terms in a result set and distill the result text down to the pertinent parts"
  s.authors     = ["Devin Austin"]
  s.email       = 'devin.austin@gmail.com'
  s.files       = ["lib/fluorescent.rb"]
  s.homepage    =
    'http://rubygems.org/gems/fluorescent'
  s.license       = 'MIT'
  s.add_runtime_dependency "activerecord", "~> 4.2"
  s.add_development_dependency "rake", "10.4.2"
  s.add_development_dependency "minitest", "5.5.1"
end
