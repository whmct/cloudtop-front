#!/usr/bin/env ruby

system "sudo su cloudtop"
system "echo $USER >> /opt/cloudtop/debug"
system "ruby --version > /opt/cloudtop/ruby_v"
system "cd /opt/cloudtop/web/current && bundle install"
system "/opt/cloudtop/web/current/bin/rails server &"
system "sudo su"
