" File: baidu-translator.vim
" Author: lee
" Description: 
" Last Modified: 六月 08, 2020

let g:baidu_translator_api_host="https://api.fanyi.baidu.com/api/trans/vip/translate"

let g:debug_switch = 0

function s:md5(text) abort
  if executable("md5")
    return trim(system("md5 -q -s " . a:text))
  elseif executable("md5sum")
    return trim(system("echo -n ". a:text."| md5sum")[0:-3])
  end
  echoerr "can't found md5 program."
endfunction

function BaiduTranslate(from, to, text) abort

  if !exists("g:baidu_translator_appid")
    echoerr "you need to set 'let g:baidu_translator_appid=xxxxx'"
    return
  end

  let text = substitute(a:text, "\\n\\s*", " ", "g")
  let text = substitute(text, "\\.\\s", ".\n", "g")

  let l:salt = "3329757864"
  let l:sign = s:md5(g:baidu_translator_appid . "\"". text . "\"" . l:salt . g:baidu_translator_secret_key)

  " curl -s -d data --data-urlencode "q=%s" https://api.fanyi.baidu.com/api/trans/vip/translate | jq -r 'trans_result[0] | .dst .src'
  let l:command = 'curl -s -d "' .
        \ '&from=' . a:from .
        \ '&to=' . a:to .
        \ '&appid=' . g:baidu_translator_appid . 
        \ '&salt=' . l:salt . 
        \ '&sign=' . l:sign . 
        \ '" ' .
        \ '--data-urlencode "q='.text.'"' .
        \ " ". g:baidu_translator_api_host .
        \ "| jq -r '.trans_result[] | .src,.dst'"

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
  let l:result = substitute(l:result, '\r', '\n','g')
  let l:lines = split(l:result, '\n')

  let l:temp = tempname()
  call writefile(l:lines, l:temp, "a")
  exec 'pedit '.l:temp.'|wincmd P|nnoremap <buffer> q :bd<CR>|wincmd p'

  call setreg(reg, reg_save)
endfunction

nnoremap <expr> <Plug>BaiduTranslate <SID>opfunc('setup')
nnoremap <expr> <Plug>BaiduTranslateSentence 'mz'.<SID>opfunc('setup').'as`z'
