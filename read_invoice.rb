#!/usr/bin/ruby
require 'pry'
require_relative 'lib/invoice.rb'
require_relative 'lib/lineitem.rb'

inv_files = 'sca_invoices/Invoice_*.txt'

Dir.glob(inv_files) do |inv_file|
	inv=Invoice.new(inv_file)
	if inv.valid?
		puts "successfully read invoice ##{inv.invnum}"
	else
		puts "invoice file #{inv_file} is questionable, maybe something went wrong!"
	end
end

binding.pry
