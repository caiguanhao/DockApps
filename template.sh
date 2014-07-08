#!/bin/bash

cat <<'EOF'
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

echo /usr/bin/open \"$1\"
