# first install jsonld and raptor: 
#   npm install -g jsonld-cli
#   npm install -g raptor

BASE=ZplaatHUA.catnr.123916-links

jsonld normalize $BASE.json > $BASE.nq

rapper -i nquads $BASE.nq -o turtle $BASE.nq \
  -f 'xmlns:def="https://waterlandsarchief.nl/def/"' \
> $BASE.ttl 

