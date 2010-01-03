# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{posterous}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jordan Dobson"]
  s.date = %q{2009-06-11}
  s.default_executable = %q{posterous}
  s.description = %q{The Posterous gem provides posting to Posterous.com using your email, password, site id(if you have multiple sites) and your blog content. With this gem, you have access to add an entry on posterous by providing these options a title, body text, date, tags, set to autopost, set private, posted by source name and a posted by source link to Posterous. You can include no options, all options or anything in between. 

Posting images with posts, posting only images and pulling down your posts will be available very soon.}
  s.email = ["jordan.dobson@madebysquad.com"]
  s.executables = ["posterous"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/posterous", "lib/posterous.rb", "test/test_posterous.rb"]
  s.homepage = %q{http://github.com/jordandobson/Posterous/tree/master}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{posterous}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{The Posterous gem provides posting to Posterous.com using your email, password, site id(if you have multiple sites) and your blog content}
  s.test_files = ["test/test_posterous.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.12.2"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.12.2"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.12.2"])
  end
end
