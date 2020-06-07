let g:baidu_translator_appid="20200607000488675"
let g:baidu_translator_secret_key="Nb_cT61hFraVEUpkvp33"
let g:baidu_translator_api_host="https://api.fanyi.baidu.com/api/trans/vip/translate"

let g:debug_switch = 0

function BaiduTranslate(from, to, text) abort

  if !exists("g:baidu_translator_appid")
    echoerr "you need to set 'let g:baidu_translator_appid=xxxxx'"
    return
  end

  let l:salt = "3329757864"
  let l:sign = system("md5 -q -s " . (g:baidu_translator_appid . "\"". a:text . "\"" . l:salt . g:baidu_translator_secret_key))
  let l:sign = trim(l:sign)

  " curl -s -d data --data-urlencode "q=%s" https://api.fanyi.baidu.com/api/trans/vip/translate | jq -r 'trans_result[0] | .dst .src'
  let l:command = "curl -s -d " . '"' . 
        \ '&from=' . a:from .
        \ '&to=' . a:to .
        \ '&appid=' . g:baidu_translator_appid . 
        \ '&salt=' . l:salt . 
        \ '&sign=' . l:sign . 
        \ '" ' .
        \ '--data-urlencode "q='.a:text.'"' .
        \ " ". g:baidu_translator_api_host .
        \ "| jq -r '.trans_result[] | .src + \"\r\" +  .dst'"

  let l:result = system(l:command)
  return l:result
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
  elseif a:type ==# "v" || a:type ==# "V" || a:type ==# "\<C-V>"
    let ve = &virtualedit
    if !(a:0 && a:1)
      set virtualedit=
    endif
    silent exe 'norm! gv"'.reg.'y'
    let &virtualedit = ve
  end

  let l:result = BaiduTranslate("cn", "zh", escape(@", "\"'\\/"))
  let l:temp = tempname()
  let l:result = substitute(l:result, '\r', '\n','g')
  let l:lines = split(l:result, '\n')
  call writefile(map(l:lines, 'trim(v:val)'), l:temp, "a")
  exec 'pedit '.l:temp.'|wincmd P|nnoremap <buffer> q :bd<CR>'

  call setreg(reg, reg_save)
endfunction

nnoremap <expr> <Plug>BaiduTranslate <SID>opfunc('setup')
nmap gs <Plug>BaiduTranslate
vnoremap gs :<c-u>call <SID>opfunc(visualmode(), visualmode() ==# 'V' ? 0 : 1)<cr>
