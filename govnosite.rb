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

##
## Git initialization and first commit
##

git :init

# Dirs should contain at least one file to be tracked by git
run("find . \\( -type d -empty \\) -and \\( -not -regex ./\\.git.* \\) -exec touch {}/.gitignore \\;")


# Creating global .gitignore
# Ignoring swaps, docs, logs and schema.rb
# Migrations is the only thru about db schema, not schema.rb!
#
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

# Only database.yml.example should be stored in git for security reasons!
run "cp config/database.yml config/database.yml.example"

git :add => "."
git :commit => "-a -m 'Setting up a new rails app. Copy config/database.yml.example to config/database.yml and customize.'"

### 
### We need some info about ongoing project
###
puts 'Some questions about ongoing project:'
uses_jquery = yes('Uses jQuery?')
uses_exception_notification = yes('Need exception_notifier?')
uses_aasm = yes('Need finite state machines?')
uses_asset_packager = yes('Need asset packaging?')

###
### Let's setup gems and plugin dependencies
###

# Rails plugins as git submodules

# Always use it:
plugin('will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :submodule => true)

# Customizable
plugin('asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true) if uses_asset_packager
plugin('jrails', :git => 'git://github.com/aaronchi/jrails.git', :submodule => true) if uses_jquery
plugin('exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true) if uses_exception_notification


# Some useful gems
# gem 'rubyist-aasm'

# Freezing gems
rake("gems:install", :sudo => true)
rake("gems:unpack")

git :submodule => "init", :add => '.', :commit => "-a -m 'Useful plugins as submodules and unpacked gems'"

###
### Generating base migrations and other stuff
###

generate("authlogic", "user session")

###
### DB: migration, population
###
rake("db:migrate")
