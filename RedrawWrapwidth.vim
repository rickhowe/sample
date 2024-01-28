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
    " find ww and other prop/extmark in this buffer
    let pl = #{0: [], 1: []}
    if has('nvim')
      for [ns, id] in items(nvim_get_namespaces())
        let wl = (ns == ww)
        let pl[wl] += map(nvim_buf_get_extmarks(bn, id, 0, -1,
                                      \#{details: v:true}), '[v:val[1] + 1] +
                  (wl ? [v:val[2] + 1, len(v:val[3].virt_text[0][0])] : [])')
      endfor
    else
      for pt in prop_type_list()
        let wl = (pt == ww)
        let pl[wl] += map(prop_list(1, #{bufnr: bn, end_lnum: -1,
                                                              \types: [pt]}),
                  \'[v:val.lnum] + (wl ? [v:val.col, len(v:val.text)] : [])')
      endfor
    endif
    " find lines to redraw
    let rl = []
    for [ln, co, vl] in pl.1
      if index(rl, ln) == -1 &&
                            \(virtcol([ln, co], 1)[0] + vl - 1 + to) % tw != 0
        " ww vt exists at other column than right edge
        let rl += [ln]
      endif
    endfor
    call map(pl.1, 'v:val[0]')
    for [ln] in pl.0
      if index(pl.1 + rl, ln) == -1
        " other vt exists in other line than ww
        let rl += [ln]
      endif
    endfor
    " disable and then enable ww on each redraw line
    for ln in rl
      if has_key(bv[ww].lw, ln)
        call execute(map([0, bv[ww].lw[ln]], 'ln . "Wrapwidth " . v:val'))
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
