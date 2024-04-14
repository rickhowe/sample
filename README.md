# difffilter

## Filter diff lines

The standard "diff" command has "-I REGEXP" or
"--ignore-matching-lines=REGEXP" option to ignore a hunk if all the inserted
and deleted lines match REGEXP. This plugin provides similar functionality but
tries a line-based filtering according to not only REGEXP but also other
requirement/condition/criteria.

For example, vim will show such differences for these 3 files:

![sample1](sample1.png)

This plugin gets vim to ignore comment lines so that you can focus on the
"return" statement in 3 files.

![sample2](sample2.png)

Internally, this plugin sets a function to `diffexpr` option to:
* evaluate if each line is to-be-compared or not by using an expression
  set in a `DiffFilterExpr` tabpage-local or global variable.
* set a special symbol to not-to-be-compared lines in 2 files
* call a builtin diff function to compare them
* modify diff hunks to allow vim to handle to-be-compared lines only

You need to set a boolean expression in `t:DiffFilterExpr` or
`g:DiffFilterExpr` variable. In above example, the following lambda
expression is specified to ignore comment lines.
```
let g:DiffFilterExpr = {lnum -> getline(lnum) !~ '^\s*["#]'}
```
To ignore comment lines for  all filetypes commonly, specify to check a syntax
highlighting on each line:
```
let g:DiffFilterExpr = {lnum -> synIDtrans(synID(lnum,
                      \match(getline(lnum), '\S') + 1, 0)) != hlID('Comment')}
```
To use the last selected Visual area or current visible lines:
```
let g:DiffFilterExpr = {lnum -> line("'<") <= lnum && lnum <= line("'>")}
let g:DiffFilterExpr = {lnum -> line('w0') <= lnum && lnum <= line('w$')}
```
To compare lines not including a multibyte character:
```
let g:DiffFilterExpr = {lnum -> getline(lnum) !~ '[^\x00-\x7F]'}
```
To select unindented lines or unfolded lines:
```
let g:DiffFilterExpr = {lnum -> indent(lnum) == 0}
let g:DiffFilterExpr = {lnum -> foldlevel(lnum) == 0}
```
It is possible to specify a custom function:
```
let g:DiffFilterExpr = function('MyDiffFilterExpr1')
function MyDiffFilterExpr1(lnum)
  let text = getline(a:lnum)
  return text =~ '\d' && 1 < count(text, '|')
endfunction
```
```
let g:DiffFilterExpr = function('MyDiffFilterExpr2')
function MyDiffFilterExpr2(lnum)
  return getline(a:lnum - 1)[0] = '{' && getline(a:lnum + 1)[0] = '}'
endfunction
```
As a default, this plugin sets `hl-Conceal` to visualize which line is not
diff compared and conceal them. To hide those lines, use `conceallevel` and
`concealcursor` options. Disable `t:DiffFilterConceal` or
`g:DiffFilterConceal` variable if not necessary,

Use `:diffupdate` command to reevaluate and redraw diff lines when something
is changed.

### Options

* `t:DiffFilterExpr`, `g:DiffFilterExpr`
  * An boolean expression to evaluate if a line is to-be-compared or not
    (default: {-> 1}).
* `t:DiffFilterConceal`, `g:DiffFilterConceal`
  * Enable (1) or disable (0) to highlight other lines than diff compared in
    `hl-Conceal` (default: 1).
* `g:NoDiffFilter`
  * Enable (0) or disable (1) this plugin (default: 0).

### Requirements

This plugin requires a builtin diff function:
* `diff()` and patch-9.1.0099 in vim 9.1
* Lua `vim.diff()` in nvim 0.6.0
