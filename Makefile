define ask
	@while true; \
	do echo "\n> $1.app"; \
	echo "Enter a path relative to $3 or a URL \
	you want to open:"; \
	echo "Enter a dash (\"-\") if you don't want to make this app."; \
	read makepath; \
	if [ "$$makepath" = "-" ]; then \
	break; \
	fi; \
	./make.sh --dry-run --$2 "$$makepath"; \
	echo "Is this OK? Enter to continue, Ctrl-C to quit, type any thing to restart. \c"; \
	read answer; \
	if [ ! -z "$$answer" ]; then \
	continue; \
	fi; \
	./make.sh --$2 "$$makepath"; \
	break; \
	done
endef

all:
	$(call ask,GitHub,github,https://github.com/)
	$(call ask,Wikipedia,wikipedia,http://en.wikipedia.org/)
	$(call ask,YouTube,youtube,http://www.youtube.com/)
	$(call ask,Twitter,twitter,https://twitter.com/)

clean:
	rm -rf *.app

install:
	cp -r *.app /Applications/

.PHONY: clean install all
