#!/usr/bin/ruby

require 'pty'
require 'expect'

fnames = []
PTY.spawn("csession cache -UVISTA '^ZU'") do |r_f,w_f,pid|
   w_f.sync = true

   $expect_verbose = true

   #r_f.expect(/The authenticity of host/) do
   #  w_f.print "y\n"
   #end

   r_f.expect(/^ACCESS CODE: /) do
     w_f.print "innovat3\r"
   end

   r_f.expect(/^VERIFY CODE: /) do
     w_f.print "innovat3.\r"
   end

   r_f.expect(/^Select TERMINAL TYPE NAME: /) do
     w_f.print "C-VT100\r"
   end

   r_f.expect(/Option: /) do
     #w_f.print "innovat3\n"
     print "\n-----------------------\n"
     print "Successfully logged in.\n"
     print "-----------------------\n"
     w_f.print "\r\r\r"
   end

#   if !ENV['USER'].nil?
#     username = ENV['USER']
#   elsif !ENV['LOGNAME'].nil?
#     username = ENV['LOGNAME']
#   else
#     username = 'guest'
#   end

#   r_f.expect('word:') do
#     w_f.print username+"@\n"
#   end
#   r_f.expect("> ") do
#     w_f.print "cd pub/ruby\n"
#   end
#   r_f.expect("> ") do
#     w_f.print "dir\n"
#   end

#   r_f.expect("> ") do |output|
#     for x in output[0].split("\n")
#       if x =~ /(ruby.*\.tar\.gz)/ then
#          fnames.push $1
#       end
#     end
#   end
   begin
     w_f.print "quit\n"
   rescue
   end
end
