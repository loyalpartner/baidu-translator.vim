appid="20200607000488675"
secret_key="Nb_cT61hFraVEUpkvp33"
translate_api_host="https://api.fanyi.baidu.com/api/trans/vip/translate"
salt="3329757864"
q="$@"
# sign=`md5 -q -s "$appid$q$salt$secret_key"` mac
sign=`md5sum <<<"$appid$q$salt$secret_key" | cut -d " " -f 1`
echo "q=$q&from=en&to=zh&appid=$appid&salt=$salt&sign=$sign"  
curl -s -d "q=$q&from=en&to=zh&appid=$appid&salt=$salt&sign=$sign"  "$translate_api_host" 
# | jq  -r '.trans_result[] | .dst + .src' 
