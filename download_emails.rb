#!/usr/bin/ruby
require 'net/pop'

require_relative 'email_secrets.rb'
pop = Net::POP3.new(EmailSecrets::HOSTNAME)
pop.enable_ssl
pop.start(EmailSecrets::ACCOUNT, EmailSecrets::PASSWORD)

if pop.mails.empty?
	puts 'No mail.'
else
	puts 'Downloading new emails...'
	pop.each_mail do |m|
		File.open("inbox/#{m.uidl}", 'w') do |f|
			f.write m.pop
			m.delete
		end
	end
	puts "#{pop.mails.size} emails saved."
end
pop.finish
