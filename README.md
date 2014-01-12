DockApps
========

Open your favorite websites in the dock.

This shell script will download app icon in png format and convert them to an .icns icon. A small .app file will be created and it contains shell script to open website in your default browser.

![screenshot](https://f.cloud.github.com/assets/1284703/1896367/c7b07ebe-7b99-11e3-89c4-ab177da3bc05.png)

Usage
-----

If you have GNU make installed, open terminal, ``cd`` to the repository directory and run:

    make
    make install

and you'll be asked which apps to make and what URL the app will open. After that, the apps will be copied to /Applications/ directory. You will be asked if you want to add those apps to your dock.

If you don't have GNU make, you can also open terminal, ``cd`` to the repository directory and run:

    ./make.sh

it will build all apps with default URLs.

    make.sh accepts these arguments:

        --help, -h               Show this help and exit.
        --dry-run, -d            Do not make. Show URLs.
        --github <URL>           Make GitHub.app.
        --wikipedia <URL>        Make Wikipedia.app.
        --youtube <URL>          Make YouTube.app.
        --twitter <URL>          Make Twitter.app.

    <URL> is relative to default URL of each app if it is
    not started with http:// or https://.

To see list of default URLs of selected apps:

    ./make.sh --dry-run --github "" --wikipedia ""

Example:

    ./make.sh --github "caiguanhao?tab=repositories" \
        --youtube "feed/subscriptions" --wikipedia - --twitter -

Apps
----

### GitHub

* [GitHub icon file](https://github.com/fluidicon.png) can be found in the source code of GitHub web page.

### YouTube

* [YouTubee icon file](http://www.youtube.com/yt/brand/media/image/YouTube-icon-full_color.png) can be downloaded on the YouTube's [Brand Assets Download](http://www.youtube.com/yt/brand/downloads.html) web page.

### Twitter

* [Twitter icon file](https://g.twimg.com/Twitter_logo_blue.png) can be downloaded on the Twitter's [Brand assets and guidelines](https://about.twitter.com/press/brand-assets) web page.

### Wikipedia

* [Wikipedia icon file](http://upload.wikimedia.org/wikipedia/en/thumb/8/80/Wikipedia-logo-v2.svg/1024px-Wikipedia-logo-v2.svg.png) can be found Wikipedia's [web page](http://en.wikipedia.org/wiki/File:Wikipedia-logo-v2.svg).

Developers
----------

* caiguanhao &lt;caiguanhao@gmail.com&gt;
