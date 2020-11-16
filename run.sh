# first install jsonld and raptor: 
#   npm install -g jsonld-cli
#   npm install -g raptor

# BASE=data/ZplaatHUA.catnr.123916-links
URL=http://www.documentatie.org/data/ZoekplaatDb/ZplaatUitzicht/ZplaatUitzicht-HUA.catnr.84347/
BASE=data/ZplaatUitzicht-1870.catnr.84347-PANDENframe

./ImageAreaParser.py --html $BASE.htm --base_url $URL  > $BASE.json

jsonld normalize $BASE.json > $BASE.nq

rapper -i nquads $BASE.nq -o turtle $BASE.nq \
  -f 'xmlns:def="http://documentatie.org/def/"' \
  -f 'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' \
  -f 'xmlns:sdo="https://schema.org/"' \
> $BASE.ttl 

echo $BASE.json
echo $BASE.ttl 

ttl $BASE.ttl 

if test $? -eq 0
then
  echo "ok"
  ./kladblok.sh "$BASE.ttl"

else
  echo "error"
fi