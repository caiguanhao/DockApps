#!/bin/bash

set -e

help()
{
  cat <<HELP
$0 --app <NAME> --url <URL> --location <PATH> [--dock] [--pptp]
HELP
}

while [ $# -gt 0 ]; do
  case "$1" in
    --app)      shift; app_name="$1";     shift ;;
    --url)      shift; app_url="$1";      shift ;;
    --location) shift; app_location="$1"; shift ;;
    --dock)     shift; add_to_dock=1;           ;;
    --pptp)     shift; app_template=1;          ;;
    *) echo Unknown option or value: $1; exit 1 ;;
  esac
done

if [ -z "${app_location}" ]; then
  echo "Please provide --location, like '--location /Applications/DockApps'"
  exit 1
fi

app_dir="${app_location}/${app_name}.app"
app_iconset_dir="${app_dir}/Contents/Resources/${app_name}.iconset"

download()
{
  if [ -e "${app_dir}" ]; then
    rm -rf "${app_dir}"
  fi
  mkdir -p "${app_iconset_dir}"
  cd "${app_iconset_dir}"
  case "$1" in
    *.zip)
      curl -Lso "/tmp/tmp.zip" "$1"
      unzip -oq "/tmp/tmp.zip" -d "/tmp"
      ;;
    *)
      curl -Lso "${app_name}.png" "$1"
      ;;
  esac
}

case "$app_name" in
  BitBucket)
    download "https://cloud.githubusercontent.com/assets/1284703/4429566/d4d812fe-45f2-11e4-85e2-70feebdf64ec.png"
    sips -z 1024 1024 "${app_name}.png" >/dev/null
    ;;
  Dropbox)
    download "http://icons.iconarchive.com/icons/uiconstock/socialmedia/512/Dropbox-icon.png"
    sips -z 1024 1024 "${app_name}.png" >/dev/null
    ;;
  Facebook)
    download "http://img2.wikia.nocookie.net/__cb20130501121248/logopedia/\
images/thumb/f/fb/Facebook_icon_2013.svg/1024px-Facebook_icon_2013.svg.png"
    sips -p 1024 1024 "${app_name}.png" >/dev/null
    ;;
  Flowdock)
    download "https://www.flowdock.com/fluid-icon.png"
    sips -z 1024 1024 "${app_name}.png" >/dev/null
    ;;
  GitHub)
    download "https://github.com/fluidicon.png"
    sips -z 1024 1024 "${app_name}.png" >/dev/null
    ;;
  Gmail)
    download "https://upload.wikimedia.org/wikipedia\
/commons/thumb/4/45/New_Logo_Gmail.svg/1024px-New_Logo_Gmail.svg.png"
    sips -p 1024 1024 "${app_name}.png" >/dev/null
    ;;
  npm)
    download "https://raw.githubusercontent.com/npm/logos/\
373398ec73257954872124f3224ff90e62f2635c/%22npm%22%20lockup/npm.png"
    sips -Z 1024 -p 1024 1024 "${app_name}.png" >/dev/null
    ;;
  Instagram)
    download "http://static.ak.instagram.com/press/brand-assets/Instagram_Icon_Large.zip"
    mv /tmp/Instagram_Icon_Large.png "${app_name}.png"
    sips -z 1024 1024 "${app_name}.png" >/dev/null
    ;;
  Trello)
    # http://interestingjohn.deviantart.com/art/Trello-Shadow-Box-Icon-331867074
    download "http://fc04.deviantart.net/fs70/f/2012/285/8/e/trello_shadow_box_icon_by_interestingjohn-d5hl29u.zip"
    mv "/tmp/Trello Box.icns" "../${app_name}.icns"
    SKIPICNS=1
    ;;
  Twitter)
    download "https://g.twimg.com/Twitter_logo_blue.png"
    sips -Z 1024 -p 1024 1024 "${app_name}.png" >/dev/null
    ;;
  Wikipedia)
    download "http://upload.wikimedia.org/wikipedia\
/en/thumb/8/80/Wikipedia-logo-v2.svg/1024px-Wikipedia-logo-v2.svg.png"
    sips -p 1024 1024 "${app_name}.png" >/dev/null
    ;;
  YouTube)
    download "https://www.youtube.com/yt/about/media/downloads/full-color-icon.zip"
    mv "/tmp/Full Color Icon/For Web/YouTube-icon-full_color.png" "${app_name}.png"
    sips -p 1024 1024 "${app_name}.png" >/dev/null
    ;;
  *)
    help
    exit 0
    ;;
esac

if [ -z "$SKIPICNS" ]; then
  sips -z 16 16   "${app_name}.png" --out "icon_16x16.png"    >/dev/null
  sips -z 32 32   "${app_name}.png" --out "icon_32x32.png"    >/dev/null
  sips -z 128 128 "${app_name}.png" --out "icon_128x128.png"  >/dev/null
  sips -z 256 256 "${app_name}.png" --out "icon_256x256.png"  >/dev/null
  sips -z 512 512 "${app_name}.png" --out "icon_512x512.png"  >/dev/null

  cp   "icon_32x32.png"   "icon_16x16@2x.png"
  sips -z 64 64   "${app_name}.png" --out "icon_32x32@2x.png" >/dev/null
  cp   "icon_256x256.png" "icon_128x128@2x.png"
  cp   "icon_512x512.png" "icon_256x256@2x.png"
  cp   "${app_name}.png"  "icon_512x512@2x.png"

  cd ..

  iconutil -c icns "${app_name}.iconset" >/dev/null
  rm -rf "${app_name}.iconset"
else
  cd ..
fi

cd ..

cat > "Info.plist" <<FILE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleExecutable</key>
<string>${app_name}</string>
<key>CFBundleIconFile</key>
<string>${app_name}</string>
</dict>
</plist>
FILE

mkdir -p "MacOS"

case "$app_template" in
  1)
    cat > "MacOS/${app_name}" <<'EOF'
#!/bin/bash

# Start PPTP VPM service
IFS=$'\n'
for PPTP in $(scutil --nc list | awk '$6 == "PPTP" { print }' | awk -F'"' '{ print $2 }'); do
  scutil --nc show "$PPTP" | grep 'CommRemoteAddress' -q && {
    scutil --nc start "$PPTP"
    while [[ $(scutil --nc status "$PPTP" | head -1) == "Connecting" ]]; do
      sleep 0.5
    done
    break
  }
done

EOF
    echo /usr/bin/open \"${app_url}\" >> "MacOS/${app_name}"
    ;;
  *)
    echo \#\!/bin/bash > "MacOS/${app_name}"
    echo /usr/bin/open \"${app_url}\" >> "MacOS/${app_name}"
    ;;
esac

chmod +x "MacOS/${app_name}"

cd ../..

case "$add_to_dock" in
  1)
    defaults write com.apple.dock persistent-apps -array-add "<dict>
      <key>tile-data</key>
      <dict>
        <key>file-data</key>
        <dict>
          <key>_CFURLString</key>
          <string>${app_dir}</string>
          <key>_CFURLStringType</key>
          <integer>0</integer>
        </dict>
      </dict>
    </dict>"
    sleep 2
    ;;
esac
