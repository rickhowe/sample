" vim: ts=4 sw=4

if !exists('g:loaded_2html_plugin')
	finish
endif

function! s:dcharTOhtml(sl, el)
	if !exists('t:DChar')
		call tohtml#Convert2HTML(a:sl, a:el)
	else
		" disable current syntax (because impossible to mix with DChar ones)
		syntax off
		" set DChar unit syntax from getmatches()
		let gps = {}
		for k in [1, 2]
			call win_gotoid(t:DChar.wid[k])
			let gm = getmatches()
			for md in values(t:DChar.mid[k])
				for id in md
					for gi in range(len(gm))
						if gm[gi].id == id
							for [ky, vl] in items(gm[gi])
								if ky =~ 'pos\d\+' && len(vl) == 3
									let gp = gm[gi].group
									let gps[gp] = []
									execute('syntax match ' . gp .
												\' /\%' . vl[0] . 'l\%>' .
												\(vl[1] - 1) . 'c.\+\%<' .
												\(vl[1] + vl[2] + 1) . 'c/')
								endif
							endfor
							unlet gm[gi]
							break
						endif
					endfor
				endfor
			endfor
		endfor
		" call TOhtml
		call tohtml#Convert2HTML(a:sl, a:el)
		" change the highlight on DChar unit in html
		if !empty(gps)
			let [dc, dt] = ['DiffChange', 'DiffText']
			let lc = [line('.'), col('.')]
			" (1) DT -> DC (2) DChar unit + DC -> DChar unit
			execute('silent %s/<span class="[^"]\{-}\zs\<' . dt .
											\'\>\ze[^"]\{-}">/' . dc . '/ge')
			execute('silent %s/<span class="[^"]\{-}\<\(' .
								\join(keys(gps), '\|') . '\)\>\zs \+\<' . dc .
													\'\>\ze[^"]\{-}">//ge')
			call cursor(lc)
		endif
		" resume the original syntax
		syntax on
	endif
endfunction

command! -range=% -bar TOhtml call s:dcharTOhtml(<line1>, <line2>)
