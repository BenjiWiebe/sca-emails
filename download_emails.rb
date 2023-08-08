#!/usr/bin/ruby
require 'net/pop'

hostname='mail.jasonwiebedairy.com'
account='sca_process@benjiwiebe.com'
password='[_QQ[\'4&j;+2tt;?T}r2'

pop = Net::POP3.new(hostname)
pop.enable_ssl
pop.start(account, password)

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
