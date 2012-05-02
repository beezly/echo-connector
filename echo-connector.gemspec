Gem::Specification.new do |s|
  s.name 	= 'echo-connector'
  s.version	= '0.0.3'
  s.date	= '2012-04-19'
  s.summary	= 'Echo360 API Connector'
  s.description = 'Echo360 API Connector for Ruby'
  s.authors 	= ["Andrew Beresford"]
  s.email	= 'beezly@beez.ly'
  s.files	= ["lib/echo-connector.rb"]
  s.homepage 	= 'http://github.com/beezly/echo-connector'
  s.add_dependency 'nokogiri', '>= 1.5.2'
  s.add_dependency 'oauth', '>= 0.4.6'
  s.add_dependency 'nori', '>= 1.1.0'
end
