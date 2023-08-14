#!/usr/bin/ruby
require 'pry'
class Invoice
	# lineitmes will be an array of LineItem
	# the rest will probably be text fields for now. no dollar signs in front of the prices.
	attr_accessor :invnum, :invdate, :duedate, :lineitems, :total, :trackingnumbers, :ordernumber, :ponumber
	#TODO add initializer where we pass the text filename to it.
end
class LineItem
	# qtyordered, qtyshipped shall be integers
	# partno, description, msrp, cost, totalamount shall be text fields. no dollar signs in front of the prices.
	attr_accessor :qtyordered, :qtyshipped, :partno, :description, :msrp, :cost, :totalamount, :details
	def initialize
		@details = []
	end
end


f=File.open('Invoice_INV70535195.txt')
state = :header
all_line_items_text = []
skip_next_lines = 0

thisinvoice = Invoice.new
thisinvoice.trackingnumbers = ""
f.each_line do |line|
	if skip_next_lines > 0
		puts "skipped line"
		skip_next_lines =- 1
		next
	end
	case state
	when :order_po
		if /^(?<ordernumber>SO\d{6,})\s+(?<ponumber>\w+)\s+/ =~ line
			thisinvoice.ordernumber = ordernumber
			thisinvoice.ponumber = ponumber
		else
			puts "error on PO# line, doesn't match regex"
		end
		state = :header # we arent done with the header, there's still tracking numbers to go yet
	when :header
		if /Invoice:(?<invnum>INV\d{8,})$/ =~ line
			thisinvoice.invnum = invnum
		elsif /Date:\s*(?<invdate>\d{1,2}\/\d{1,2}\/\d{4})$/ =~ line
			thisinvoice.invdate = invdate
		elsif /^Order #\s+PO #\s+/ =~ line
			state = :order_po
		elsif /^\s+Tracking Number\(s\)\s+$/ =~ line
			state = :trackingnumbers
		elsif /\s(?<invnum>INV\d{8,})\s+(?<duedate>\d+\/\d+\/\d+)\s+\$(?<total>\d+\.\d+)$/ =~ line
			thisinvoice.invnum = invnum
			thisinvoice.duedate = duedate
			thisinvoice.total = total
		end
	when :trackingnumbers
		if /^\s*$/ =~ line
			state = :unknown
		else
			thisinvoice.trackingnumbers += line.strip
		end
	when :unknown
		if /^Ordered[[:space:]]+Shipped$/ =~ line
			puts "Found ordered-shipped line"
			state = :lineitems
			skip_next_lines = 1 # ordered-shipped line is followed by one blank line, which would otherwise signify the end of the line items
		end
	when :lineitems
		if /^[[:space:]]*\d+ of \d+$/ =~ line
			puts "found 'n of n' line"
			state = :unknown
		elsif /^[[:space:]]*$/ =~ line
			puts "found blank line"
			state = :unknown
		else
			puts "found line item"
			all_line_items_text << line
		end
	end
end

# Here, we have the line items in an array of lines. Let's split it into per-part entries
all_lineitems = []
this_lineitem = nil
all_line_items_text.each do |line|
	if /^\s+(?<ordered>\d+)\s+(?<shipped>\d+)\s+(?<partno>[ \w[[:space:]]]{3,})\s+\$(?<msrp>\d+\.\d+)\s+\$(?<cost>\d+\.\d+)\s+\$(?<total>\d+\.\d+)\s*$/ =~ line
		this_lineitem = LineItem.new
		this_lineitem.qtyordered = ordered
		this_lineitem.qtyshipped = shipped
		this_lineitem.partno = partno.strip # remove leading and trailing whitespace
		this_lineitem.msrp = msrp
		this_lineitem.cost = cost
		this_lineitem.totalamount = total
		all_lineitems << this_lineitem
	else
		this_lineitem.details << line.strip #remove leading and trailing whitespace
	end
end
binding.pry
f.close
