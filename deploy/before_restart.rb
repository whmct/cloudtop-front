#!/usr/bin/env ruby

run "echo $USER >> /opt/cloudtop/debug"
run "ruby --version > /opt/cloudtop/ruby_v"
run "cd /opt/cloudtop/web/current && bundle install"
run "/opt/cloudtop/web/current/bin/rails server &"
