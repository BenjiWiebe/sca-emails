#!/usr/bin/ruby
require 'pry'
class Invoice
	# lineitems will be an array of LineItem
	# the rest will probably be text fields for now. no dollar signs in front of the prices.
	attr_accessor :invnum, :invdate, :duedate, :lineitems, :total, :trackingnumbers, :ordernumber, :ponumber, :freight, :subtotal
	#TODO add initializer where we pass the text filename to it.
	def initialize(filename)
		@lineitems = []
		f=File.open(filename)
		state = :header
		skip_next_lines = 0
		
		@trackingnumbers = ""
		grouped_lines = []
		f.each_line do |line|
			if skip_next_lines > 0
				puts "skipped line"
				skip_next_lines =- 1
				next
			end
			case state
			when :order_po
				if /^(?<ordernumber>SO\d{6,})\s+(?<ponumber>\w+)\s+/ =~ line
					@ordernumber = ordernumber
					@ponumber = ponumber
				else
					puts "error on PO# line, doesn't match regex"
				end
				state = :header # we arent done with the header, there's still tracking numbers to go yet
			when :header
				if /Invoice:(?<invnum>INV\d{8,})$/ =~ line
					@invnum = invnum
				elsif /Date:\s*(?<invdate>\d{1,2}\/\d{1,2}\/\d{4})$/ =~ line
					@invdate = invdate
				elsif /^Order #\s+PO #\s+/ =~ line
					state = :order_po
				elsif /^\s+Tracking Number\(s\)\s+$/ =~ line
					state = :trackingnumbers
				elsif /\s(?<invnum>INV\d{8,})\s+(?<duedate>\d+\/\d+\/\d+)\s+\$(?<total>\d+\.\d+)$/ =~ line
					@invnum = invnum
					@duedate = duedate
					@total = total
				end
			when :trackingnumbers
				if /^\s*$/ =~ line
					state = :unknown
				else
					@trackingnumbers += line.strip
				end
			when :unknown
				if /^Ordered[[:space:]]+Shipped$/ =~ line
					puts "Found ordered-shipped line"
					state = :lineitems
					skip_next_lines = 1 # ordered-shipped line is followed by one blank line, which would otherwise signify the end of the line items
				elsif /^\s+Subtotal\s+\$(?<subtotal>\d+\.\d+)$/ =~ line
					@subtotal = subtotal
				elsif /^\s+Freight Total\s+\$(?<freight>\d+\.\d+)$/ =~ line
					@freight = freight
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
					# THIS SHOULD WORK EXCEPT IF TWO INFO LINES ARE IN A ROW
					# The below regex is copied from LineItem.initialize minus the named fields. Please keep them in sync.
					if /^\s+\d+\s+\d+\s+[ \w[[:space:]]]{3,}\s+\$\d+\.\d+\s+\$\d+\.\d+\s+\$\d+\.\d+\s*$/ =~ line
						if grouped_lines.count > 0
							@lineitems << LineItem.new(grouped_lines)
							grouped_lines = []
						end
					end
					grouped_lines << line
				end
			end # case state
		end # f.each_line
		if grouped_lines.count > 0
			@lineitems << LineItem.new(grouped_lines)
		end
		f.close
		@trackingnumbers = @trackingnumbers.split
	end # def initialize

	def valid?
		# TODO check validity of all invoice fields, not just the lineitems!
		lineitems_invalid = @lineitems.any? {|i| !i.valid? }
		dollar_figure = /^\d+\.\d{0,2}$/
		problems = false
		unless dollar_figure =~ @freight
			problems = true
		end
		unless dollar_figure =~ @subtotal
			problems = true
		end
		unless dollar_figure =~ @total
			problems = true
		end
		unless /^SO\d+$/ =~ @ordernumber
			problems = true
		end
		unless /^INV\d+$/ =~ @invnum
			problems = true
		end
		if lineitems_invalid
			problems = true
		end
		return !problems
	end # def valid?
end	# class Invoice

class LineItem
	# qtyordered, qtyshipped shall be integers
	# partno, description, msrp, cost, totalamount shall be text fields. no dollar signs in front of the prices.
	attr_accessor :qtyordered, :qtyshipped, :partno, :description, :msrp, :cost, :totalamount, :details
	def initialize(group_of_lines)
		@details = []
		puts "group of lines count = #{group_of_lines.count}"
		group_of_lines.each do |line|
			if /^\s+(?<ordered>\d+)\s+(?<shipped>\d+)\s+(?<partno>[ \w[[:space:]]]{3,})\s+\$(?<msrp>\d+\.\d+)\s+\$(?<cost>\d+\.\d+)\s+\$(?<total>\d+\.\d+)\s*$/ =~ line # This regex is copied to Invoice.initialize. Please keep them in sync.
				@qtyordered = ordered
				@qtyshipped = shipped
				@partno = partno.strip # remove leading and trailing whitespace
				@msrp = msrp
				@cost = cost
				@totalamount = total
			else
				@details << line.strip #remove leading and trailing whitespace
			end
		end # 
	end # def initialize
	def valid?
		# this regex matches numbers with two decimal places, like '20.55' or '5.10'
		dollar_figure = /^\d+\.\d{0,2}$/
		problems = false
		if @qtyordered.to_i <= 0 # qty shipped or back ordered might be 0, but ordered should be >0
			problems = true
		end
		unless dollar_figure =~ @cost
			problems = true
		end
		unless dollar_figure =~ @msrp
			problems = true
		end
		unless dollar_figure =~ @totalamount
			problems = true
		end
		return !problems
	end
end # class LineItem

inv=Invoice.new('Invoice_INV70535195.txt')
unless inv.valid?
	puts "invoice is questionable, maybe something went wrong!"
end
binding.pry


