
# GEONATURE FRONTEND
url_test="http://localhost:8081/geonature"
res=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "${url_test}")
echo "$url_test -> $res"
[ "$res" = "200" ] || [ "$res" = "301" ] || exit 1

# GEONATURE BACKEND
url_test="http://localhost:8081/geonature/api/gn_commons/config"
res=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "${url_test}")
echo "$url_test -> $res"
[ "$res" = "200" ] || [ "$res" = "301" ] || exit 1

# USERSHUB
url_test="http://localhost:8081/usershub/login"
res=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "${url_test}")
echo "$url_test -> $res"
[ "$res" = "200" ] || [ "$res" = "301" ] || exit 1

# TAXHUB
url_test="http://localhost:8081/taxhub/"
res=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "${url_test}")
echo "$url_test -> $res"
[ "$res" = "200" ] || [ "$res" = "301" ] || exit 1

# ATLAS
url_test="http://localhost:8081/atlas/"
res=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "${url_test}")
echo "$url_test -> $res"
[ "$res" = "200" ] || [ "$res" = "301" ] || exit 1
