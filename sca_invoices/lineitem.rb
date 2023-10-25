class LineItem
	# qtyordered, qtyshipped shall be integers
	# partno, description, msrp, cost, totalamount shall be text fields. no dollar signs in front of the prices.
	attr_accessor :qtyordered, :qtyshipped, :partno, :description, :msrp, :cost, :totalamount, :details
	def initialize(group_of_lines)
		@details = []
		#puts "group of lines count = #{group_of_lines.count}"
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
