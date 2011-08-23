#!/usr/bin/env ruby

# protfolio.rb
# written and maintained by Johannes Held
# USE AT OWN RISK

require 'yahoofinance'

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

if __FILE__ == $0
	l = ARGV.join(',')
	qs = get_quote_info(l)
	qs.each do |s,v|
		puts "#{s}:\t#{v.lastTrade}"
	end
end
