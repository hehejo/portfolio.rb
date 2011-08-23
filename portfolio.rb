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

if __FILE__ == $0
	portfolio = load_portfolio
	quote_list = Array.new
	portfolio.each do |p|
		quote_list << p['stock']
	end

	qs = get_quote_info(quote_list.join(','))
	qs.each do |s,v|
		puts "#{s}:\t#{v.lastTrade}"
	end
end
