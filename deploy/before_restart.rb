#!/usr/bin/env ruby

system "echo $USER"
system "source ~/.bash_profile"
system "ruby --version > /opt/cloudtop/ruby_v"
system "cd /opt/cloudtop/web/current && bundle install"
system "/opt/cloudtop/web/current/bin/rails server &"
