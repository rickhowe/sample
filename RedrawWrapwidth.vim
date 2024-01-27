function! s:RedrawWrapwidth() abort
  let ww = 'wrapwidth'
  let wn = win_getid()
  let bn = winbufnr(wn)
  let bv = getbufvar(bn, '')
  if has_key(bv, ww)
    let bn = winbufnr(wn)
    let wi = getwininfo(wn)[0]
    let [tw, to] = (&cpoptions =~ 'n') ?
                          \[wi.width, wi.textoff] : [wi.width - wi.textoff, 0]
    let rl = []
    for [ln, co, vl] in has('nvim') ?
          \map(nvim_buf_get_extmarks(bn, nvim_get_namespaces()[ww], 0, -1,
                                                        \#{details: v:true}),
            \'[v:val[1] + 1, v:val[2] + 1, len(v:val[3].virt_text[0][0])]') :
          \map(prop_list(1, #{end_lnum: -1, bufnr: bn, types: [ww]}),
                                  \'[v:val.lnum, v:val.col, len(v:val.text)]')
      if index(rl, ln) == -1 &&
                            \(virtcol([ln, co], 1)[0] + vl - 1 + to) % tw != 0
        " this virtual space is displayed at other column than right edge,
        " redraw this line
        call execute(map([0, bv[ww].lw[ln]], 'ln . "Wrapwidth " . v:val'))
        let rl += [ln]
      endif
    endfor
  endif
endfunction

nnoremap <silent> <C-L> :<C-U>call <SID>RedrawWrapwidth()<CR><C-L>

"let &updatetime = 500
"augroup redrawwrapwidth
  "autocmd!
  "autocmd! CursorHold * call <SID>RedrawWrapwidth()
"augroup END
