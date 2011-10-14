#! /usr/bin/env ruby -w
# encoding=utf-8
# when2sell.rb
# written and maintained by Johannes Held
# USE AT OWN RISK

require 'optparse'

class When2Sell

	attr_reader(:kaufbetrag, :anzahl)

	# Initialize important values
	# @param kauf_betrag the amount of money you payed at buy
	# @param anzahl_aktien how many stocks do you have?
	# @param provision_kurswert in % the provision on kurswert @ sell
	# @üaram prov_min the minimum amount of provion
	def initialize(kauf_betrag, anzahl_aktien, provision_kurswert, prov_min = 0)
		@kaufbetrag = kauf_betrag
		@anzahl = anzahl_aktien
		@provision = provision_kurswert / 100.0
		@prov_min = prov_min
		sell_by_x_to_save
	end

	# Calculate the stock value to save at least _savings_
	# @param savings the amount of money to save
	# @retun [Float] the stock value to sell at
	def sell_by_x_to_save(savings = 0)
		@kmin = (@kaufbetrag + @prov_min + savings) / (@anzahl * (1 - @provision))
	end

	# Print a report with information about the provision, sums, …
	# @return [String] the report
	def report
rep=<<EOR
Verkauf von %i Aktien bei Kurswert %.3f €:
Betrag:      %8.3f €
Provision:   %8.3f €
-----------------------
Endbetrag:   %8.3f €
Kaufbetrag:  %8.3f €

EOR

		betrag = __betrag(@kmin)
		provision =  __provision(@kmin)
		endbetrag = betrag - provision
		puts rep % [@anzahl, @kmin, betrag, provision, endbetrag, @kaufbetrag]
	end

	private
	# calculate the provision
	# @param kurs stock value
	# @param anzahl amount of stocks
	# @return [Float] provision to pay 
	def __provision(kurs)
		p = kurs * @anzahl * @provision
		return @prov_min if p < @prov_min
		return p
	end

	# calculate the actual value of stock
	# @param kurs sock value
	# @param anzahl amount of stocks
	# @return [Float] kurs * anzahl
	def __betrag(kurs)
		kurs * @anzahl
	end

end

if __FILE__ == $0
		options = {:amount => 100,
		 	:kaufbetrag => 6501,
		 	:provision => 0.25,
			:prov_min => 9.90}

		optparse = OptionParser.new do |opts|
			opts.on('-a' , '--amount AMOUNT', Integer, 'set the amount of stocks') do |a|
				options[:amount] = a
			end

			opts.on('-k' , '--kaufbetrag BETRAG', Float, 'set the order value') do |a|
				options[:kaufbetrag] = a
			end

			opts.on('-p' , '--provision PROVISION', Float, 'set the provision in %') do |a|
				options[:provision] = a
			end

			opts.on('-m' , '--min_provision PROVISION_MIN', Float, 'set the minumum provision in €') do |a|
				options[:prov_min] = a
			end
		end
		optparse.parse!
	
	seller = When2Sell.new(options[:kaufbetrag],
												 options[:amount],
												 options[:provision],
												 options[:prov_min])

	seller.report
	seller.sell_by_x_to_save(120)
	seller.report
end

