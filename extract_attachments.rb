#!/usr/bin/ruby
require 'mail'
require 'pry'

def write_attachments(prefix, mail)
	num_wrote = 0
	mail.attachments.each do |at|
		next if File.exists?(prefix + at.filename)
		File.write(prefix + at.filename, at.body.decoded)
		puts "Wrote attachment #{at.filename}"
		num_wrote += 1
	end
	return num_wrote
end

recent_filename='inbox/recent'

most_recent = File.read(recent_filename).to_i
while ! File.exists?("inbox/#{most_recent}") && most_recent
	most_recent -= 1
end
File.write(recent_filename, most_recent)

(most_recent + 1).times do |i|
	puts "reading email number #{i}"
	mail = Mail.read("inbox/#{i}")
	num_wrote = write_attachments('invoices/', mail)
	if num_wrote == mail.attachments.count
		puts "Deleting email #{i}"
		File.delete("inbox/#{i}")
	end
end

#mail = Mail.read('inbox/0')
#binding.pry
