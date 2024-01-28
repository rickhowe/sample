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
    let pl = {}
    if has('nvim')
      for [ns, id] in items(nvim_get_namespaces())
        let pl[ns] = map(nvim_buf_get_extmarks(bn, id, 0, -1,
                                                        \#{details: v:true}),
              \'[v:val[1] + 1, v:val[2] + 1, has_key(v:val[3], "virt_text") ?
                                        \len(v:val[3].virt_text[0][0]) : 0]')
      endfor
    else
      for pt in prop_type_list()
        let pl[pt] = map(prop_list(1, #{bufnr: bn, end_lnum: -1,
                                      \types: [pt]}), '[v:val.lnum, v:val.col,
                              \has_key(v:val, "text") ? len(v:val.text) : 0]')
      endfor
    endif
    " find lines to redraw
    for pt in [ww] + filter(keys(pl), 'v:val != ww')
      if pt == ww
        let rl = []
        for [ln, co, vl] in pl[pt]
          " check if ww vt is displayed at other column than right edge
          if index(rl, ln) == -1 &&
                            \(virtcol([ln, co], 1)[0] + vl - 1 + to) % tw != 0
            let rl += [ln]
          endif
        endfor
        let wl = map(pl[pt], 'v:val[0]')
      else
        for [ln, co, vl] in pl[pt]
          " check if other vt than ww is displayed at other line than ww
          if index(wl, ln) == -1 | let rl += [ln] | endif
        endfor
      endif
    endfor
    " disable ww and then enable ww on echo redraw line
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
