#!/usr/bin/env ruby
# encoding=utf-8
# protfolio.rb
# written and maintained by Johannes Held
# USE AT OWN RISK

require 'yahoofinance'
require 'yaml'

# file for portfolio
PORTFOLIO=File.expand_path '~/.portfolio'

# Query yahoofinance information about quotes
# @param quotes list of comma-separated yahoo quote identifiers
# @return [Hash] a hash of quote identifiers poiting to their finance information
def get_quote_info(quotes = '')
	ret = Hash.new
	YahooFinance::get_quotes(YahooFinance::StandardQuote, quotes) do |qt|
		ret[qt.symbol] = qt
	end
	return ret
end

# load the portfolio
# @return [Array] an array of hashes with information about the portfolio
def load_portfolio
	return YAML.load(File.read(PORTFOLIO))
end

# construct the quote list for querying the stock information
# @parm portfolio the portfolio (Array loaded from the dataset)
# @return [String] comma-separted stock names
def get_quote_list(portfolio = Array.new)
	quote_list = Array.new
	portfolio.each do |p|
		quote_list << p['stock']
	end
	return quote_list.join(',')
end

# calculates profit for the given portfolio
# @parm portfolio the portfolio (array with hashes loaded from the dataset)
# @return [Hash] updated with profitinformation query with "profit_percent" and "profit_amount" 
def calculate_portfolio(portfolio = Array.new)
	qs = get_quote_info(get_quote_list(portfolio))
	portfolio.each do |p|
		p['info'] = qs[p['stock']]
		value_orderd = p['amount']*p['price']
		value_now = p['amount']*p['info'].lastTrade
		p['profit_amount'] = value_now - value_orderd
	end
	return portfolio
end

# printing the actual portfolio
# @parm portfolio the portfolio (array with hashes loaded from the dataset)
def print_portfolio(portfolio = Array.new)
	template=<<EOT
STOCK:\tLASTTRADE €
\tAMOUNT @ PRICE € -> PROFIT €
EOT
	money = portfolio.reduce(0) do |memo, p|
		t = template.dup
		t.sub!('STOCK', p['stock'])
		t.sub!('LASTTRADE', "#{p['info'].lastTrade}")
		t.sub!('AMOUNT', p['amount'].to_s)
		t.sub!('PRICE', p['price'].to_s)
		t.sub!('PROFIT', p['profit_amount'].to_s)
		puts t
		memo += p['profit_amount']
	end
	puts "-> #{money} €"
end

if __FILE__ == $0
	portfolio = calculate_portfolio load_portfolio
	print_portfolio portfolio

end
