#!/bin/bash

apikey=  #get an account at worldweatheronline.com

if [[ -z "$*" ]]; then
echo "Enter query in any of the following formats: city | city, country | latitude,longitude | IP address"

else
q=$(echo -ne "$*" | sed 's/ /+/g' | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g')
xml=$(curl -s "http://free.worldweatheronline.com/feed/weather.ashx?q="$q"&format=xml&num_of_days=2&key=$apikey")

loc=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'query' --text_only)
temp=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'temp_C' --text_only)
cond=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'weatherDesc' --text_only)
winds=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'windspeedKmph' --text_only)
windd=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'winddirDegree' --text_only)
winddn=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'winddir16Point' --text_only)
precip=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'precipMM' --text_only)
humid=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'humidity' --text_only)
visib=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'visibility' --text_only)
press=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'pressure' --text_only)
cloud=$(echo $xml | /usr/bin/vendor_perl/xml_grep 'current_condition' - | /usr/bin/vendor_perl/xml_grep 'cloudcover' --text_only)

echo "Location: "$loc" Temperature: "$temp"°C Condition: "$cond" Wind Speed: "$winds" km/h Wind Direction: "$windd"°"$winddn" Precipitation: "$precip" mm Humidity: "$humid"% Visibility: "$visib" Pressure: "$press" mb Cloudcover: "$cloud"%"

fi

exit 0
