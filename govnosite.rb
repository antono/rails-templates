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
run "rm public/rails.png"
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
file '.gitignore', "log/\\*.log
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
"

# Only database.yml.example should be stored in git for security reasons!
run "cp config/database.yml config/database.yml.example"

git :add => "."
git :commit => "-a -m 'Setting up a new rails app. Copy config/database.yml.example to config/database.yml and customize.'"

###
### Let's setup gems and plugin dependencies
###

# Rails plugins as git submodules
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
plugin 'asset_packager', :git => 'git://github.com/sbecker/asset_packager.git', :submodule => true
plugin 'authlogic', :git => 'git://github.com/binarylogic/authlogic.git', :submodule => true
plugin 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :submodule => true
plugin 'jrails', :git => 'git://github.com/aaronchi/jrails.git', :submodule => true

# Some useful gems
gem 'rubyist-aasm'

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
