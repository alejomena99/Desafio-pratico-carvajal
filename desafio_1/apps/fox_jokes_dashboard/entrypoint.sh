#!/bin/sh
API_URL=${API_URL:-"https://gateway.com"}
cat <<EOF > /usr/share/nginx/html/env/env.js
window._env_ = {
  API_URL: "$API_URL"
};
EOF
exec "$@"