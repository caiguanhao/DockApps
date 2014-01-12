#!/bin/sh

set -e

make_app()
{
  local app_name="$1"
  local app_url="$2"
  local app_dir="${app_name}.app"
  local app_iconset_dir="${app_dir}/Contents/Resources/${app_name}.iconset"

  if [ -e "${app_dir}" ]; then
    rm -rf "${app_dir}"
  fi

  mkdir -p "${app_iconset_dir}"

  cd "${app_iconset_dir}"

  echo "Downloading ${app_name} icon... \c"
  case "$app_name" in
  GitHub)
    curl -Lso "${app_name}.png" "https://github.com/fluidicon.png"
    sips -z 1024 1024 "${app_name}.png" > /dev/null
    ;;
  YouTube)
    curl -Lso "${app_name}.png" "http://www.youtube.com/yt/brand/media\
/image/YouTube-icon-full_color.png"
    sips -p 1024 1024 "${app_name}.png" > /dev/null
    ;;
  Twitter)
    curl -Lso "${app_name}.png" "https://g.twimg.com/Twitter_logo_blue.png"
    sips -Z 1024 -p 1024 1024 "${app_name}.png" > /dev/null
    ;;
  Wikipedia)
    curl -Lso "${app_name}.png" "http://upload.wikimedia.org/wikipedia\
/en/thumb/8/80/Wikipedia-logo-v2.svg/1024px-Wikipedia-logo-v2.svg.png"
    sips -p 1024 1024 "${app_name}.png" > /dev/null
    ;;
  *)
    rm -rf "${app_dir}"
    echo "Error: App name does not exist."
    exit 1
    ;;
  esac
  echo "OK"

  echo "Making iconset... \c"
  sips -z 16 16   "${app_name}.png" --out "icon_16x16.png"    > /dev/null
  sips -z 32 32   "${app_name}.png" --out "icon_32x32.png"    > /dev/null
  sips -z 128 128 "${app_name}.png" --out "icon_128x128.png"  > /dev/null
  sips -z 256 256 "${app_name}.png" --out "icon_256x256.png"  > /dev/null
  sips -z 512 512 "${app_name}.png" --out "icon_512x512.png"  > /dev/null

  cp   "icon_32x32.png"   "icon_16x16@2x.png"
  sips -z 64 64   "${app_name}.png" --out "icon_32x32@2x.png" > /dev/null
  cp   "icon_256x256.png" "icon_128x128@2x.png"
  cp   "icon_512x512.png" "icon_256x256@2x.png"
  cp   "${app_name}.png"  "icon_512x512@2x.png"
  echo "OK"

  cd ..

  echo "Making icns... \c"
  iconutil -c icns "${app_name}.iconset"
  rm -rf "${app_name}.iconset"
  echo "OK"

  cd ..

  echo "Creating Info.plist... \c"
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
  echo "OK"

  mkdir -p "MacOS"

  echo "Making executable... \c"
  cat > "MacOS/${app_name}"  <<FILE
#!/bin/sh
/usr/bin/open "${app_url}"
FILE
  chmod +x "MacOS/${app_name}"
  echo "OK"

  cd ../..
}

make_app "GitHub" "https://github.com/"
make_app "Wikipedia" "http://en.wikipedia.org/"
make_app "YouTube" "http://www.youtube.com/feed/subscriptions"
make_app "Twitter" "https://twitter.com/"
