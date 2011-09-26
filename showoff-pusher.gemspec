# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "showoff/pusher"

Gem::Specification.new do |s|
  s.name        = "showoff-pusher"
  s.version     = ShowOff::Pusher::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Use Pusher to drive your Showoff presentations on remote machines."
  s.email       = "blakesgentry@gmail.com"
  s.homepage    = "http://github.com/bgentry/showoff-pusher"
  s.description = "Use Pusher to drive your Showoff presentations on remote machines."
  s.authors     = ['Blake Gentry', 'Larry Marburger']

  s.rubyforge_project = "showoff-pusher"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency("showoff", "~> 0.7.0")
  s.add_dependency("pusher",  "~> 0.8.3")
end
