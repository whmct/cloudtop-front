
# we should bundle install
system "env > /tmp/env"
system "which ruby > /tmp/ruby_where"
system "rvm list > /tmp/rvm_list"
system "cd #{release_path};bundle install"
