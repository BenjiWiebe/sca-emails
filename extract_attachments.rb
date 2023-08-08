#!/usr/bin/ruby
require 'mail'
require 'pry'

# Writes attachments from email
# returns number of attachments written
# prefix is concat'ed with filename, no slash added.
def write_attachments(prefix, mail)
	num_wrote = 0
	mail.attachments.each do |at|
		if File.exists?(prefix + at.filename)
			puts "Error - file #{at.filename} exists already! Skipping."
			next
		end
		File.write(prefix + at.filename, at.body.decoded)
		puts "Wrote attachment #{at.filename}"
		num_wrote += 1
	end
	return num_wrote
end

if ! Dir.exist?('old')
	FileUtils.mkdir('old')
end

if ! Dir.exist?('sca_invoices')
	FileUtils.mkdir('sca_invoices')
end

Dir.foreach('inbox/') do |f|
	next if File.directory? f #needed to skip . and ..
	puts "reading email #{f}"
	mail = Mail.read("inbox/#{f}")
	num_wrote = write_attachments('sca_invoices/', mail)
	if num_wrote == mail.attachments.count
		puts "Deleting email #{f}"
		FileUtils.move("inbox/#{f}", "old/")
	else
		puts "Something went wrong - wrote #{num_wrote} attachments, email had #{mail.attachments.count} attachments"
		exit 1
	end
end
