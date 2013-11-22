" vim: et sw=2 sts=2

scriptencoding utf-8

" Function: #get_others {{{1
function! sy#sign#get_others() abort
  let s:other_signs_line_numbers = {}

  let lang = v:lang
  silent! execute 'language C'

  redir => signlist
    silent! execute 'sign place buffer='. b:sy.buffer
  redir END

  for line in filter(split(signlist, '\n'), 'v:val =~ "^\\s\\+line"')
    let lnum = matchlist(line, '\v^\s+line\=(\d+)')[1]
    let s:other_signs_line_numbers[lnum] = 1
  endfor

  silent! execute 'language' lang
endfunction

" Function: #set {{{1
function! sy#sign#set(signs)
  let hunk = { 'ids': [], 'start': a:signs[0].lnum, 'end': a:signs[-1].lnum }

  for sign in a:signs
    " Preserve non-signify signs
    if !g:signify_sign_overwrite && has_key(s:other_signs_line_numbers, sign.lnum)
      continue
    endif

    call add(hunk.ids, g:id_top)
    execute 'sign place' g:id_top 'line='. sign.lnum 'name='. sign.type 'buffer='. b:sy.buffer

    let g:id_top += 1
  endfor

  call add(b:sy.hunks, hunk)
endfunction

" Function: #remove_all {{{1
function! sy#sign#remove_all(bnum) abort
  let sy = getbufvar(a:bnum, 'sy')

  if g:signify_sign_overwrite
    execute 'sign unplace * buffer='. sy.buffer
  else
    for hunk in sy.hunks
      for id in hunk.ids
        execute 'sign unplace' id
      endfor
    endfor
  endif

  let sy.hunks = []
  let sy.stats = [0, 0, 0]
endfunction
