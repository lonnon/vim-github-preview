" markdown.vim - Preview markdown with GitHub styling
" Language: Markdown
" Maintainer: Lonnon Foster <lonnon@lonnon.com>
" URL: https://github.com/lonnon/vim-markdown-preview
" License: MIT
" Dependencies: python, mistune, pygments

if exists("b:loaded_markdown_preview")
  finish
endif

let b:loaded_markdown_preview = 1

function! s:ShowMarkdownPreview(line1, line2)
  let text = getline(a:line1, a:line2)
  let os = s:GetOS()
  let tmp_dir = s:GetTempDir(os)

  let md_file = tmp_dir . "markdown-preview.md"
  let html_file = tmp_dir . "markdown-preview.html"

  call writefile(text, md_file)
  call s:ConvertMarkdown(md_file, html_file, os)
  call s:DisplayHTML(html_file, os)
endfunction

function! s:GetOS()
  if g:uname != ''
    let uname = g:uname
  else
    let uname = system("uname -a")
  endif

  if has('mac') || has('macunix')
    let s:tmp_dir = '/tmp/'
    return 'mac'
  elseif match(uname, 'Microsoft') > -1
    " Windows WSL
    return 'wsl'
  elseif has('unix')
    return 'unix'
  elseif has('win32') || has('win64') || has('win16')
    return 'windows'
  endif
endfunction

function! s:GetTempDir(os)
  if a:os == 'mac' || a:os == 'unix'
    return '/tmp/'
  elseif a:os == 'wsl'
    " Lop newlines off the end of wslpath output
    let appdata = system("wslpath '" . $APPDATA . "'")[:-2]
    let vimtmp = appdata . '/vim/tmp/'
    if isdirectory(vimtmp) == 'FALSE'
      call system('mkdir -p ' . vimtmp)
    endif
    return vimtmp
  elseif a:os == 'windows'
    let vimtmp = $APPDATA . '\vim\tmp\'
    if isdirectory(vimtmp) == 'FALSE'
      call system('mkdir ' . vimtmp)
    endif
    return vimtmp
  endif
endfunction

function! s:ConvertMarkdown(md_file, html_file, os)
  if a:os == 'mac' || a:os == 'unix'
    call system('multimarkdown ' . a:md_file . ' > ' . a:html_file)
  elseif a:os == 'wsl' || a:os == 'windows'
    call system('multimarkdown "' . a:md_file . '" -o "' . a:html_file . '"')
  endif
endfunction

function! s:DisplayHTML(html_file, os)
  if a:os == 'mac'
    call system('open ' . a:html_file)
  elseif a:os == 'wsl'
    let winpath = system('wslpath -w ' . a:html_file)
    let escpath = substitute(winpath, '\', '\\\\', 'g')
    exec '!cmd.exe /c start' escpath
  elseif a:os == 'unix'
    call system('gnome-open ' . a:html_file)
  elseif a:os == 'windows'
    call system('"' . a:html_file . '"')
  endif
endfunction

command! -range=% MarkdownPreview call s:ShowMarkdownPreview(<line1>, <line2>)
command! -range=% MdP call s:ShowMarkdownPreview(<line1>, <line2>)
