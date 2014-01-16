#!/usr/bin/env ruby

system "cd /opt/cloudtop/web/current && bundle install"
system "/opt/cloudtop/web/current/bin/rails server &"
