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
	@echo "Apps have been copied to /Applications directory."
	@echo "Do you want to add those apps to your dock?"
	@echo "Type yes to continue, anything else to break. \c"; \
	read answer; \
	if [ "$$answer" = "yes" ]; then \
	for app in $$(ls -d *.app); \
	do defaults write com.apple.dock persistent-apps -array-add "<dict> \
	  <key>tile-data</key> \
	  <dict> \
	    <key>file-data</key> \
	    <dict> \
	      <key>_CFURLString</key> \
	      <string>/Applications/$$app</string> \
	      <key>_CFURLStringType</key> \
	      <integer>0</integer> \
	    </dict> \
	  </dict> \
	</dict>"; \
	done; \
	killall Dock; \
	fi

.PHONY: clean install all
