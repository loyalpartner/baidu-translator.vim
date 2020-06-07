appid="20200607000488675"
secret_key="Nb_cT61hFraVEUpkvp33"
translate_api_host="https://api.fanyi.baidu.com/api/trans/vip/translate"
salt="3329757864"
q="$@"
sign=`md5 -q -s "$appid$q$salt$secret_key"`
echo "q=$q&from=en&to=zh&appid=$appid&salt=$salt&sign=$sign&1"  
curl -s -d "q=$q&from=en&to=zh&appid=$appid&salt=$salt&sign=$sign"  "$translate_api_host" | jq '.trans_result[] | .dst + "\r" + .src'
