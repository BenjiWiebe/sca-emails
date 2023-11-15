#!/usr/bin/ruby
require 'net/pop'
require 'pry'

require_relative 'email_secrets.rb'
pop = Net::POP3.new(EmailSecrets::HOSTNAME)
pop.enable_ssl
pop.start(EmailSecrets::ACCOUNT, EmailSecrets::PASSWORD)

if pop.mails.empty?
	puts 'No mail.'
else
	puts "Downloading #{pop.mails.length} new emails..."
	pop.each_mail do |m|
		File.open("inbox/#{m.uidl}", 'w') do |f|
			f.write m.pop
			m.delete
		end
		print '.'
	end
	puts
	puts "#{pop.mails.size} emails saved."
end
pop.finish
