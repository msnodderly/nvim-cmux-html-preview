" Live-preview hooks for cmux. Saving an HTML buffer reloads the preview
" pane; entering a different HTML buffer navigates the pane to that page.
" Requires `preview start` to be running — otherwise the hooks are no-ops.
"
" Load per-session:        vim -S preview.vim <file>.html
" Or from inside vim:      :source preview.vim
" Or from project config:  see the README's .nvim.lua example.
"
" The preview command is resolved in order: g:preview_cmd if set, a
" `preview` script next to this file, then `preview` on $PATH.

if exists('g:loaded_cmux_preview')
  finish
endif
let g:loaded_cmux_preview = 1

if exists('g:preview_cmd')
  let s:cmd = g:preview_cmd
elseif executable(expand('<sfile>:p:h') . '/preview')
  let s:cmd = expand('<sfile>:p:h') . '/preview'
else
  let s:cmd = 'preview'
endif

function! s:Sync() abort
  call system(s:cmd . ' sync ' . shellescape(expand('%:p')) . ' &')
endfunction

augroup CmuxPreview
  autocmd!
  autocmd BufWritePost,BufEnter *.html call s:Sync()
augroup END

" Sync the buffer that's already open when this script is sourced.
if expand('%:p') =~? '\.html$'
  call s:Sync()
endif
