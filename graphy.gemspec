Gem::Specification.new do |s|
  s.name        = 'graphy'
  s.version     = '0.1'
  s.platform    = Gem::Platform::RUBY
  #s.authors     = []
  #s.email       = []
  #s.homepage    = ''
  #s.summary     = ''
  #s.description = ''
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = [ 'lib' ]
  s.extra_rdoc_files = [ 'README.md' ]

  s.add_development_dependency('debugger')
  s.add_dependency('debugger')
  s.add_development_dependency('rspec', '~>2.0')
  s.add_dependency('rspec', '~>2.0')
  s.add_dependency('algorithms', '~>0.6')
  s.add_runtime_dependency('algorithms', '~>0.6')
end

