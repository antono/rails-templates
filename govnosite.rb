### -*- coding: utf-8 -*-
###
### Govnosite Template for Rails
###

##
## Initial files setup
##

run "echo TODO > README"
run "rm doc/README_FOR_APP"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/images/rails.png"
file 'public/robots.txt', "User-Agent: *\nAllow: /"


git :init

run("find . \\( -type d -empty \\) -and \\( -not -regex ./\\.git.* \\) -exec touch {}/.gitignore \\;")

file '.gitignore', <<-EOF
log/\\*.log
log/\\*.pid
db/\\*.db
db/\\*.sqlite3
db/schema.rb
tmp/\\*\\*/\\*
doc/api
doc/app
config/database.yml
\#*
*~
*.swp
.DS_Store
EOF

run "cp config/database.yml config/database.yml.example"

git :add => "."
git :commit => "-a -m 'Setting up a new rails app. Copy config/database.yml.example to config/database.yml and customize.'"

puts 'Some questions about ongoing project:'
need_jquery = yes?('Uses jQuery?')
need_aasm = yes?('Need finite state machines?')
need_asset_packager = yes?('Need asset packaging?')
need_exception_notification = yes?('Need exception_notifier?')
need_attachements = yes?('Need file or image uploads?')
need_wysiwyg = yes?('Need WYSIWYG editor?')
need_russian = yes?('Need russian gem?')

need_authorisation = yes?('Need authorisation support?')
if need_authorisation
  need_roles = yes?('Need user roles?')
end

plugin('will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :submodule => true)
plugin('asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true) if need_asset_packager
plugin('jrails', :git => 'git://github.com/aaronchi/jrails.git', :submodule => true) if need_jquery
plugin('exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true) if need_exception_notification
plugin('paperclip', :git => 'git://github.com/thoughtbot/paperclip.git', :submodule => true) if need_attachements
plugin('tiny_mce', :git => 'git://github.com/kete/tiny_mce.git', :submodule => true) if need_wysiwyg
plugin('russian', :git => 'git://github.com/yaroslav/russian.git', :submodule => true) if need_russian

if need_authorisation
  plugin('authlogic', :git => 'git://github.com/binarylogic/authlogic.git', :submodule => true)
  plugin('acl9', :git => 'git://github.com/be9/acl9.git', :submodule => true) if need_roles
end

if need_aasm
  gem 'rubyist-aasm', :source => 'http://gems.github.com'
end

gem 'ryanb-nifty-generators', :source => 'http://gems.github.com'

rake("gems:install", :sudo => true)
rake("gems:unpack")

git :submodule => "init", :add => '.', :commit => "-a -m 'Useful plugins as submodules and unpacked gems'"

generate :nifty_layout
generate :nifty_config

if need_authorisation
  generate("authlogic", "user session")
end

rake("db:migrate")
