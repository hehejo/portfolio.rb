.PHONY: doc

install: portfolio.rb
	cp portfolio.rb  ~/bin/portfolio

doc:
	yardoc .
