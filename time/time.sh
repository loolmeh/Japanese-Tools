#!/bin/bash

apikey=  #get an account at http://www.worldweatheronline.com

if [[ -z "$*" ]]; then
echo "Enter query in any of the following formats: city | city, country | latitude,longitude | IP address"

else
q=$(echo -ne "$*" | sed 's/ /+/g' | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
xml=$(curl -s "http://www.worldweatheronline.com/feed/tz.ashx?key=$apikey&q="$q"&format=xml")

time=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'localtime' --text_only)
location=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'query' --text_only)
timezone=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'utcOffset' --text_only)

echo "Location: "$location" Time Zone: UTC "$timezone" Local Time: "$time
fi

exit 0
