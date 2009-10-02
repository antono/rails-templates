### -*- coding: utf-8 -*-
###
### Govnosite Rails Template
###
def commit_all_with_message(message)
  git :add => "."
  git :commit => "-a -m \"#{message}\""
end

puts 'Some questions about ongoing project:'

need_jquery = yes?('Uses jQuery?')
need_aasm = yes?('Need finite state machines?')
need_asset_packager = yes?('Need asset packaging?')
need_exception_notification = yes?('Need exception_notifier?')
need_attachements = yes?('Need file or image uploads?')
need_wysiwyg = yes?('Need WYSIWYG editor?')
need_russian = yes?('Need russian gem?')
need_tags = yes?('Need tagging?')
need_menu = yes?('Need semantic menu')
need_all_deveopment_helpers = true

need_authorisation = yes?('Need authorisation support?')
if need_authorisation
  need_roles = yes?('Need user roles?')
end

##
## Initial git setup
##
run "rm doc/README_FOR_APP"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/images/rails.png"
run "cp config/database.yml config/database.yml.example"
file 'public/robots.txt', "User-Agent: *\nAllow: /"
file "README", <<-EOF
Git modules!
============

To start using this app you should first init and update git modules:

    $ git submodule init && git submodule upate

TODO
====
EOF

git :init

run("find . \\( -type d -empty \\) -and \\( -not -regex ./\\.git.* \\) -exec touch {}/.gitignore \\;")

file '.gitignore', <<-EOF
log/*.log
log/*.pid
db/*.db
db/*.sqlite3
db/schema.rb
tmp/**/*
tmp/*
doc/api
doc/app
config/database.yml
\#*
*~
*.swp
.DS_Store
EOF

# Nice ruby hunk-headers for git diff.
# $ git config --global diff.ruby.funcname '^ *\(\(class\|module\|def\) .*\)'
file '.gitattributes', "*.rb diff=ruby"


commit_all_with_message 'Basic setup of rails app. .gitignore, robots.txt and other stuff.'

# Plugins and gems

if need_all_deveopment_helpers
  # Notify about exceptions
  plugin('exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true) if need_exception_notification

  # Xilence removes all that annoying HTML and CSS code from your rails
  # backtrace for ajax requests
  plugin('xilence', :git => 'git://github.com/inem/xilence.git', :submodule => true)

  # Output honc(expression) to FireBug console.
  # http://rozenbom.r09.railsrumble.com/handcar
  # http://rozenbom.r09.railsrumble.com/plugins/handcar.xpi
  plugin('handcar', :git => 'git://github.com/inem/handcar.git', :submodule => true)

  # rake db:annotate
  plugin('annotate_models', :git => 'git://github.com/rotuka/annotate_models.git', :submodule => true)

  # Find unused css selectors with rake deadweight
  gem 'aanand-deadweight', :source => 'http://gems.github.com', :lib => 'deadweight'
  rakefile 'deadweight.rake' do
    <<-TASK
    # lib/tasks/deadweight.rake
    begin
      require 'deadweight'
    rescue LoadError
    ensure
      puts 'sudo gem install aanand-deadweight'
    end

    desc "run Deadweight CSS check (requires script/server)"
    task :deadweight do
      dw = Deadweight.new
      dw.stylesheets = ["/stylesheets/application.css"]
      dw.pages = ["/", "/feeds", "/about", "/episodes/archive", "/comments", "/episodes/1-caching-with-instance-variables"]
      dw.ignore_selectors = /flash_notice|flash_error|errorExplanation|fieldWithErrors/
      puts dw.run
    end
    TASK
  end
end

# uni-form helper for rails
plugin('uni-form', :git => 'git://github.com/antono/uni-form.git', :submodule => true)
# We always need a model without table...
plugin('tableless', :git => 'git://github.com/robinsp/active_record_tableless.git', :submodule => true)
plugin('more', :git => 'git://github.com/cloudhead/more.git', :submodule => true)
# favorite paginator
plugin('will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :submodule => true)
plugin('asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true) if need_asset_packager
# jQuery for rails
plugin('jrails', :git => 'git://github.com/aaronchi/jrails.git', :submodule => true) if need_jquery
plugin('paperclip', :git => 'git://github.com/thoughtbot/paperclip.git', :submodule => true) if need_attachements
plugin('tiny_mce', :git => 'git://github.com/kete/tiny_mce.git', :submodule => true) if need_wysiwyg
plugin('russian', :git => 'git://github.com/yaroslav/russian.git', :submodule => true) if need_russian
plugin('acts-as-taggable-on', :git => 'git://github.com/mbleigh/acts-as-taggable-on.git', :submodule => true) if need_tags
plugin('semantic-menu', :git => 'git://github.com/danielharan/semantic-menu.git', :submodule => true) if need_menu

if need_authorisation
  plugin('authlogic', :git => 'git://github.com/binarylogic/authlogic.git', :submodule => true)
  plugin('acl9', :git => 'git://github.com/antono/acl9.git', :submodule => true) if need_roles
end

if need_aasm
  gem 'rubyist-aasm', :source => 'http://gems.github.com', :lib => 'aasm'
end

gem 'nifty-generators', :lib => 'nifty_generators'
gem 'cucumber'
gem 'less'

rake("gems:install", :sudo => true)
rake("gems:unpack")

git :submodule => "init"

commit_all_with_message 'Useful plugins as submodules and unpacked gems'


# Generating stuff
run 'capify .'
commit_all_with_message 'Capified'

generate :nifty_layout
commit_all_with_message 'Nifty layout'

generate :nifty_config
commit_all_with_message 'Nifty config'

generate :cucumber
commit_all_with_message 'Cucumbered'

if need_tags
  generate :acts_as_taggable_on_migration
  commit_all_with_message 'Taged'
end

if need_jquery
  run 'cp vendor/plugins/uni-form/resources/public/javascripts/jquery.uni-form.js public/javascripts'
else
  run 'cp vendor/plugins/uni-form/resources/public/javascripts/uni-form.prototype.js public/javascripts'
end
run 'cp vendor/plugins/uni-form/resources/public/stylesheets/uni-form-generic.css public/stylesheets'
run 'cp vendor/plugins/uni-form/resources/public/stylesheets/uni-form.css public/stylesheets'
commit_all_with_message 'Uni-form script and css copied to public'

# sudo apt-get install linux-util
run %w{find ./public/stylesheets/ -name "*.css" -print | xargs rename "/\.css$/\.less$" }
commit_all_with_message 'Less css files'

if need_jquery
  rake("jrails:js:scrub")
  rake("jrails:js:install")
  commit_all_with_message 'Jquery scripts copied to public'
end

if need_authorisation
  generate("nifty_authentication", "--authlogic")
  commit_all_with_message 'Nifty_authentication with authlogic'
end

rake("db:migrate")
