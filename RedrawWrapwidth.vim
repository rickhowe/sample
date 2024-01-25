let s:ww = 'wrapwidth'
function! s:RedrawWrapwidth() abort
  let bn = bufnr('%')
  let bv = getbufvar(bn, '')
  if has_key(bv, s:ww) && s:FindOtherVT(bn)
    " if other virtual text is found, fire events to redraw wrapwidth
    for ev in ['BufHidden', 'BufWinEnter']
      call execute(join(['doautocmd', s:ww, ev]))
    endfor
  endif
endfunction
if has('nvim')
  function! s:FindOtherVT(bn) abort
    for [ns, id] in items(nvim_get_namespaces())
      if ns != s:ww &&
        \!empty(nvim_buf_get_extmarks(a:bn, id, 0, -1, #{type: 'virt_text'}))
        return 1
      endif
    endfor
    return 0
  endfunction
else
  function! s:FindOtherVT(bn) abort
    for pt in prop_type_list()
      if pt != s:ww && !empty(filter(prop_list(1, #{bufnr: a:bn, end_lnum: -1,
                                    \types: [pt]}), 'has_key(v:val, "text")'))
        return 1
      endif
    endfor
    return 0
  endfunction
endif

nnoremap <silent> <C-L> :<C-U>call <SID>RedrawWrapwidth()<CR><C-L>

"let &updatetime = 500
"augroup redrawwrapwidth
  "autocmd!
  "autocmd! CursorHold * call <SID>RedrawWrapwidth()
"augroup END
