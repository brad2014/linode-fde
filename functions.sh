. config.sh

#
# API helpers (since I'm too lazy to install linode-cli)
#

if ! command -v jq >/dev/null; then
  echo ERROR: jq is required but not installed.  
  exit 1
fi

function liget {
  curl -sS -H "Authorization: Bearer $LI_AUTH_TOKEN" 'https://api.linode.com/v4/linode/instances/'$1
}

function lidelete {
  curl -sS -X DELETE -H "Authorization: Bearer $LI_AUTH_TOKEN" 'https://api.linode.com/v4/linode/instances/'$1
}

function lipost {
  curl -sS \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $LI_AUTH_TOKEN" \
    -X POST -d "$2" \
    'https://api.linode.com/v4/linode/instances/'$1
}

function lirdns {
  curl -sS \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $LI_AUTH_TOKEN" \
    -X PUT -d '{"rdns": "'$2'"}' \
    https://api.linode.com/v4/networking/ips/$1
}

function liwait {
  local file=$1
  local result=$2
  local prefix=$3
  local id=$(jq -r .id < $file)
  local status=$(jq -r .status < $file)
  echo "Waiting for $prefix$id to go from $status to $result..."
  while [ "$status" != "$result" ] ; do 
    sleep 2
    liget $prefix$id > $file
    status=$(jq -r .status < $file)
    echo "status is $status"
  done
}
