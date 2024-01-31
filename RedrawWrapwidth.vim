function! s:RedrawWrapwidth() abort
  let ww = 'wrapwidth'
  let wn = win_getid()
  let bn = winbufnr(wn)
  let bv = getbufvar(bn, '')
  if has_key(bv, ww)
    let wi = getwininfo(wn)[0]
    let [tw, to] = (&cpoptions =~ 'n') ?
                          \[wi.width, wi.textoff] : [wi.width - wi.textoff, 0]
    " find ww and all other vt in this buffer
    let vt = #{0: [], 1: []}
    if has('nvim')
      for ex in nvim_buf_get_extmarks(bn, -1, 0, -1, #{details: v:true})
        if ex[3].ns_id == s:wn
          let vt.1 += [[ex[1] + 1, ex[2] + 1, len(ex[3].virt_text[0][0])]]
        else
          let vt.0 += [[ex[1] + 1]]
        endif
      endfor
    else
      for pr in prop_list(1, #{bufnr: bn, end_lnum: -1})
        if pr.type == s:ww
          let vt.1 += [[pr.lnum, pr.col, len(pr.text)]]
        else
          let vt.0 += [[pr.lnum]]
        endif
      endfor
    endif
    " find lines to redraw
    let rl = []
    for [ln, co, tn] in vt.1
      if index(rl, ln) == -1 &&
                            \(virtcol([ln, co], 1)[0] + tn - 1 + to) % tw != 0
        let rl += [ln]      " ww vt exists at other column than right edge
      endif
    endfor
    call map(vt.1, 'v:val[0]')
    for [ln] in vt.0
      if index(vt.1 + rl, ln) == -1
        let rl += [ln]      " other vt exists in other line than ww
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
