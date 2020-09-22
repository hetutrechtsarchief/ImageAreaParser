# first install jsonld and raptor: 
#   npm install -g jsonld-cli
#   npm install -g raptor

BASE=data/ZplaatHUA.catnr.123916-links

./ImageAreaParser.py --html $BASE.htm > $BASE.json

jsonld normalize $BASE.json > $BASE.nq

rapper -i nquads $BASE.nq -o turtle $BASE.nq \
  -f 'xmlns:def="http://documentatie.org/def/"' \
> $BASE.ttl 

