#!/usr/bin/ruby
require 'net/pop'

hostname='mail.jasonwiebedairy.com'
account='sca_process@benjiwiebe.com'
password='[_QQ[\'4&j;+2tt;?T}r2'
recent_filename='inbox/recent'

most_recent = File.read(recent_filename).to_i
while ! File.exists?("inbox/#{most_recent}") && most_recent >= 0
	most_recent -= 1
end
File.write(recent_filename, most_recent)

pop = Net::POP3.new(hostname)
pop.enable_ssl
pop.start(account, password)

	if pop.mails.empty?
		puts 'No mail.'
	else
		pop.each_mail do |m|
			most_recent += 1
			File.open("inbox/#{most_recent}", 'w') do |f|
			f.write m.pop
			File.write(recent_filename, most_recent)
			m.delete
		end
	end
	puts "#{pop.mails.size} emails saved."
end
pop.finish
