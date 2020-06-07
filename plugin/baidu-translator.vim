let g:baidu_translator_appid="20200607000488675"
let g:baidu_translator_secret_key="Nb_cT61hFraVEUpkvp33"
let g:baidu_translator_api_host="https://api.fanyi.baidu.com/api/trans/vip/translate"

let g:debug_switch = 0

function BaiduTranslate(from, to, text) abort

  " if !exist("baidu_translator_appid")
  "   echoerr "you need to set 'let g:baidu_translator_appid=xxxxx'"
  "   return
  " end

  let l:salt = "3329757864"
  let l:sign = system("md5 -q -s " . (g:baidu_translator_appid . "\"". a:text . "\"" . l:salt . g:baidu_translator_secret_key))
  let l:sign = trim(l:sign)

  " curl -s -d data https://api.fanyi.baidu.com/api/trans/vip/translate | jq 'trans_result[0].dst'
  " let l:command = "curl -s -d " . "\"" . 
  "       \ "q=" . a:text . 
  "       \ "&from=" . a:from .
  "       \ "&to=" . a:to .
  "       \ "&appid=" . g:baidu_translator_appid . 
  "       \ "&salt=" . l:salt . 
  "       \ "&sign=" . l:sign . 
  "       \ "\" " . g:baidu_translator_api_host .
  "       \ "| jq '.trans_result[] | .src + \"\r\" + .dst'"
  let l:command = "curl -s -d " . "\"" . 
        \ "&from=" . a:from .
        \ "&to=" . a:to .
        \ "&appid=" . g:baidu_translator_appid . 
        \ "&salt=" . l:salt . 
        \ "&sign=" . l:sign . 
        \ "\" " .
        \ "--data-urlencode \"q=".a:text."\"" .
        \ " ". g:baidu_translator_api_host .
        \ "| jq '.trans_result[] | .src + \"\r\" + .dst'"

  let l:result = system(l:command)
  return l:result
endfunction

function! s:get_visual_selection()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: column_end - 1]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

function! s:opfunc(type, ...) abort " {{{1
  if a:type ==# 'setup'
    let &opfunc = matchstr(expand('<sfile>'), '<SNR>\w\+$')
    return 'g@'
  endif

  let reg = '"'
  let reg_save = getreg(reg)
  if a:type == 'char'
    silent exe 'norm! v`[o`]"'.reg.'y'
  elseif a:type == "line"
    silent exe 'norm! `[V`]"'.reg.'y'
  end

  let l:result = BaiduTranslate("cn", "zh", s:get_visual_selection())
  let l:temp = tempname()
  let l:result = substitute(l:result, '\\r', '\n','g')
  let l:lines = split(l:result, '\n')
  call writefile(map(l:lines, 'trim(v:val)'), l:temp, "a")
  exec 'pedit '.l:temp.'|wincmd P|nnoremap <buffer> q :bd<CR>'

  call setreg(reg, reg_save)
endfunction

nnoremap <expr> <Plug>BaiduTranslate <SID>opfunc('setup')
nnoremap <expr> <Plug>BaiduTranslateV <SID>opfunc('V')

nmap gs <Plug>BaiduTranslate
vnoremap gS :<c-u><SID>opfunc('V')<cr>
