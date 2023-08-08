#!/usr/bin/ruby
f=File.open('Invoice_INV70535195.txt')
state = :unknown
all_line_items_text = []
skip_next_lines = 0
f.each_line do |line|
	if skip_next_lines > 0
		puts "skipped line"
		skip_next_lines =- 1
		next
	end
	case state
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

puts
puts
puts
puts
puts
puts 'line items:'
puts all_line_items_text
f.close
