#!/usr/bin/ruby
class Invoice
	# lineitmes will be an array of LineItem
	# the rest will probably be text fields for now. no dollar signs in front of the prices.
	attr_accessor :invnum, :invdate, :duedate, :lineitems, :total
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
f.each_line do |line|
	if skip_next_lines > 0
		puts "skipped line"
		skip_next_lines =- 1
		next
	end
	case state
	when :header
		if /Invoice:(?<invnum>INV\d{8,})$/ =~ line
			thisinvoice.invnum = invnum
		elsif /Date:\s*(?<invdate>\d{1,2}\/\d{1,2}\/\d{4})$/ =~ line
			thisinvoice.invdate = invdate
			state = :unknown
		end
	when :unknown
		if /^Ordered[[:space:]]+Shipped$/ =~ line
			puts "Found ordered-shipped line"
			state = :lineitems
			skip_next_lines = 1 # ordered-shipped line is followed by one blank line, which would otherwise signify the end of the line items
		elsif /[[:space:]](?<invnum>INV\d{8,})[[:space:]]+(?<duedate>\d+\/\d+\/\d+)[[:space:]]+\$(?<dollars>\d+)\.(?<cents>\d+)$/ =~ line
			puts "invnum = #{invnum}, duedate = #{duedate}, dollars = #{dollars}, cents = #{cents}"
			thisinvoice.invnum = invnum
			thisinvoice.duedate = duedate
			thisinvoice.total = "#{dollars}.#{cents}"
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
puts 'line items:'
puts all_line_items_text
f.close
