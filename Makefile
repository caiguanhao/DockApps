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
	$(call ask,Gmail,gmail,https://gmail.com/)

clean:
	rm -rf *.app

install:
	@echo "Copy apps to this folder: (it will be created if it doesn't exist)"; \
	echo "/Applications/\c"; \
	read directory; \
	if [ "$$OVERWRITE" != "YES" ]; then \
	for app in $$(ls -d *.app); \
	do [ -e "/Applications/$$directory/$$app" ] && \
	echo "/Applications/$$directory/$$app exists. Aborted. But you can run" && \
	echo "'OVERWRITE=YES make install' to overwrite these files." && exit 1; \
	done; \
	fi; \
	mkdir -p "/Applications/$$directory"; \
	cp -r *.app "/Applications/$$directory"; \
	echo "Apps have been copied to /Applications/$$directory."; \
	echo "Add the apps to your dock? Type 'y' to add, otherwise to break. \c"; \
	read answer; \
	if [ "$$answer" = "y" ]; then \
	for app in $$(ls -d *.app); \
	do defaults write com.apple.dock persistent-apps -array-add "<dict> \
	  <key>tile-data</key> \
	  <dict> \
	    <key>file-data</key> \
	    <dict> \
	      <key>_CFURLString</key> \
	      <string>/Applications/$$directory/$$app</string> \
	      <key>_CFURLStringType</key> \
	      <integer>0</integer> \
	    </dict> \
	  </dict> \
	</dict>"; \
	done; \
	killall Dock; \
	fi; \
	echo "Open the folder in Finder? Type 'y' to open, otherwise to break. \c"; \
	read answer; \
	if [ "$$answer" = "y" ]; then \
	open "/Applications/$$directory"; \
	fi

.PHONY: clean install all
