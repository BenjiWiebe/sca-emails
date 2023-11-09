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
			puts "Warning - file #{at.filename} exists already!"
		end
		File.write(prefix + at.filename, at.body.decoded)
		puts "Wrote attachment #{at.filename}"
		system('pdftotext', '-layout', prefix + at.filename)
		puts "Converted attachment #{at.filename} to text"
		num_wrote += 1
	end
	return num_wrote
end

if ! Dir.exist?('old_emails')
	FileUtils.mkdir('old_emails')
end

if ! Dir.exist?('sca_invoices')
	FileUtils.mkdir('sca_invoices')
end

begin
	system('pdftotext', '-help', [:out, :err] => File::NULL)
rescue
	puts "pdftotext not installed, exiting."
	exit 1
end

Dir.foreach('inbox/') do |f|
	next if File.directory? f # skip directories - needed to skip . and ..
	puts "reading email #{f}"
	mail = Mail.read("inbox/#{f}")
	num_wrote = write_attachments('sca_invoices/', mail)
	if num_wrote == mail.attachments.count
		puts "Deleting email #{f}"
		FileUtils.move("inbox/#{f}", "old_emails/")
	else
		puts "Something went wrong - wrote #{num_wrote} attachments, email had #{mail.attachments.count} attachments"
		exit 1
	end
end
puts "Done"
