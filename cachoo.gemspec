Gem::Specification.new do |s|
  s.name              = "cachoo"
  s.version           = "0.1.0"
  s.summary           = "Expirable method memoization"
  s.description       = "A quick and dirty way to expire memoization"
  s.authors           = ["elcuervo"]
  s.licenses          = ["MIT", "HUGWARE"]
  s.email             = ["yo@brunoaguirre.com"]
  s.homepage          = "http://github.com/elcuervo/cachoo"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files test`.split("\n")

  s.add_development_dependency("cutest", "~> 1.2.1")
end
