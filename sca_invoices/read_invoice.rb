#!/usr/bin/ruby
require 'pry'
require_relative 'invoice.rb'
require_relative 'lineitem.rb'
inv=Invoice.new('Invoice_INV70535195.txt')
unless inv.valid?
	puts "invoice is questionable, maybe something went wrong!"
end
binding.pry
