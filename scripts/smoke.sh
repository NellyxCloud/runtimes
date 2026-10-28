#!/bin/sh
# Smoke-test a published runtime image: it must actually serve HTTP on port 3000.
set -eu

runtime="$1"
image="$2"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
start="$tmpdir/start.sh"
mkdir -p "$tmpdir/app"

port=3000
[ "$runtime" = "static" ] && port=8080

case "$runtime" in
  node)
    cat >"$start" <<'EOF'
#!/bin/sh
exec node -e 'require("http").createServer((q,s)=>s.end("ok")).listen(process.env.PORT||3000)'
EOF
    ;;
  bun)
    cat >"$start" <<'EOF'
#!/bin/sh
exec bun -e 'Bun.serve({port: Number(process.env.PORT||3000), fetch:()=>new Response("ok")})'
EOF
    ;;
  python)
    cat >"$start" <<'EOF'
#!/bin/sh
exec python3 -m http.server "${PORT:-3000}" --bind 0.0.0.0
EOF
    ;;
  deno)
    cat >"$start" <<'EOF'
#!/bin/sh
exec deno eval 'Deno.serve({port: Number(Deno.env.get("PORT") ?? "3000")}, () => new Response("ok"))'
EOF
    ;;
  go)
    cat >"$start" <<'EOF'
#!/bin/sh
cat > /tmp/smoke.go <<'GOSRC'
package main
import ("net/http";"os")
func main(){http.ListenAndServe(":"+os.Getenv("PORT"),http.HandlerFunc(func(w http.ResponseWriter,r *http.Request){w.Write([]byte("ok"))}))}
GOSRC
exec go run /tmp/smoke.go
EOF
    ;;
  php)
    cat >"$start" <<'EOF'
#!/bin/sh
printf '<?php echo "ok";' > /tmp/index.php
exec php -S 0.0.0.0:"${PORT:-3000}" -t /tmp
EOF
    ;;
  static)
    mkdir -p "$tmpdir/app"
    printf 'ok' > "$tmpdir/app/index.html"
    cat >"$start" <<'EOF'
#!/bin/sh
exec nginx -g 'daemon off;'
EOF
    ;;
  *)
    echo "unknown runtime: $runtime" >&2
    exit 1
    ;;
esac

chmod +x "$start"

docker run -d --name smoke \
  -v "$start:/tmp/start.sh:ro" \
  -v "$tmpdir/app:/home/nellyx/app:ro" \
  -e "START_COMMAND=sh /tmp/start.sh" \
  -e "PORT=$port" \
  -p 127.0.0.1:$port:$port \
  "$image"

for _ in $(seq 1 45); do
  if curl -fsS http://127.0.0.1:$port >/dev/null 2>&1; then
    echo "$runtime responds"
    docker rm -f smoke >/dev/null
    exit 0
  fi
  sleep 1
done

echo "$runtime did not answer; container log:" >&2
docker logs smoke >&2
docker rm -f smoke >/dev/null
exit 1