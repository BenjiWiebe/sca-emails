#!/usr/bin/ruby
require 'pry'
require 'sqlite3'
require_relative 'lib/invoice.rb'
require_relative 'lib/lineitem.rb'

dbfilename = 'inv.db'
inv_files = 'sca_invoices/Invoice_*.txt'
invs_to_write = []
files_to_move = [] #move these to an archive directory if the DB commit succeeds

Dir.glob(inv_files) do |inv_file|
	tinv = Invoice.new(inv_file)
	if tinv.valid?
		puts "successfully read invoice ##{tinv.invnum}"
		invs_to_write << tinv
		files_to_move << inv_file
	else
		puts "invoice file #{inv_file} is questionable, maybe something went wrong!"
	end
end

puts "Queued #{invs_to_write.count} invoices to write to DB"

begin
	db = SQLite3::Database.open dbfilename
	stm = db.prepare 'INSERT INTO Invoice(invnum,invdate,duedate,total,trackingnumbers,ordernumber,ponumber,freight,subtotal) values (?,?,?,?,?,?,?,?,?)'
	stm2 = db.prepare 'INSERT INTO LineItems(invid,qtyordered,qtyshipped,partno,msrp,cost,totalamount,details) values (?,?,?,?,?,?,?,?)'

	db.transaction
	# start looping over inv's
	invs_to_write.each do |inv|
		stm.execute inv.invnum, inv.invdate, inv.duedate, inv.total, inv.trackingnumbers.join(' '), inv.ordernumber, inv.ponumber, inv.freight, inv.subtotal
		stm.reset!
		inv_rowid = db.last_insert_row_id
		puts "This invoice's row id is #{inv_rowid}"

		inv.lineitems.each do |lineitem|
		# loop over lineitems
			stm2.execute inv_rowid, lineitem.qtyordered, lineitem.qtyshipped, lineitem.partno,
				lineitem.msrp, lineitem.cost, lineitem.totalamount, lineitem.details.join("\n")
			stm2.reset!
		# end loop over lineitems
		end

	end #end loop over invoices
	db.commit
	# WARNING it is possible for the script to get interrupted right here and then on next run we will duplicate invoices in the DB
	# OH REALLY? doesn't the rescue/rollback prevent that? or what happens when an exception gets thrown that *isn't* SQLite3::Exception???
	# perhaps we should have a begin/rescue around this or something and warn the user. idk.
	# or we could have some more uniqueness constraints in the db, that would probably be better.
	if ! Dir.exist?('old_invoices')
	    FileUtils.mkdir('old_invoices')
	end
	files_to_move.each do |file|
		FileUtils.mv file, 'old_invoices/'
	end
rescue SQLite3::Exception => e
	puts "Exception occurred"
	puts e
	db.rollback
ensure
	stm.close if stm
	stm2.close if stm2
	db.close if db
end
