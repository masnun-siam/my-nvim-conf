if exists('g:vscode')
   " VSCode extension
    function! s:split(...) abort
        let direction = a:1
        let file = a:2
        call VSCodeCall(direction == 'h' ? 'workbench.action.splitEditorDown' : 'workbench.action.splitEditorRight')
        if file != ''
            call VSCodeExtensionNotify('open-file', expand(file), 'all')
        endif
    endfunction

    function! s:splitNew(...)
        let file = a:2
        call s:split(a:1, file == '' ? '__vscode_new__' : file)
    endfunction

    function! s:closeOtherEditors()
        call VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
        call VSCodeNotify('workbench.action.closeOtherEditors')
    endfunction

    function! s:manageEditorSize(...)
        let count = a:1
        let to = a:2
        for i in range(1, count ? count : 1)
            call VSCodeNotify(to == 'increase' ? 'workbench.action.increaseViewSize' : 'workbench.action.decreaseViewSize')
        endfor
    endfunction

    function! s:vscodeCommentary(...) abort
        if !a:0
            let &operatorfunc = matchstr(expand('<sfile>'), '[^. ]*$')
            return 'g@'
        elseif a:0 > 1
            let [line1, line2] = [a:1, a:2]
        else
            let [line1, line2] = [line("'["), line("']")]
        endif

        call VSCodeCallRange("editor.action.commentLine", line1, line2, 0)
    endfunction

    function! s:openVSCodeCommandsInVisualMode()
        normal! gv
        let visualmode = visualmode()
        if visualmode == "V"
            let startLine = line("v")
            let endLine = line(".")
            call VSCodeNotifyRange("workbench.action.showCommands", startLine, endLine, 1)
        else
            let startPos = getpos("v")
            let endPos = getpos(".")
            call VSCodeNotifyRangePos("workbench.action.showCommands", startPos[1], endPos[1], startPos[2], endPos[2], 1)
        endif
    endfunction

    function! s:openWhichKeyInVisualMode()
        normal! gv
        let visualmode = visualmode()
        if visualmode == "V"
            let startLine = line("v")
            let endLine = line(".")
            call VSCodeNotifyRange("whichkey.show", startLine, endLine, 1)
        else
            let startPos = getpos("v")
            let endPos = getpos(".")
            call VSCodeNotifyRangePos("whichkey.show", startPos[1], endPos[1], startPos[2], endPos[2], 1)
        endif
    endfunction


    command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
    command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
    command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
    command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
    command! -bang Only if <q-bang> == '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif

    " Better Navigation
    nnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
    xnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
    nnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
    xnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
    nnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
    xnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
    nnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
    xnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>

    nnoremap gr <Cmd>call VSCodeNotify('editor.action.goToReferences')<CR>

    " Bind C-/ to vscode commentary since calling from vscode produces double comments due to multiple cursors
    xnoremap <expr> <C-/> <SID>vscodeCommentary()
    nnoremap <expr> <C-/> <SID>vscodeCommentary() . '_'

    nnoremap <silent> <C-w>_ :<C-u>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>

    nnoremap <silent> <Space> :call VSCodeNotify('whichkey.show')<CR>
    xnoremap <silent> <Space> :<C-u>call <SID>openWhichKeyInVisualMode()<CR>

    xnoremap <silent> <C-P> :<C-u>call <SID>openVSCodeCommandsInVisualMode()<CR>

    xmap gc  <Plug>VSCodeCommentary
    nmap gc  <Plug>VSCodeCommentary
    omap gc  <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine
else
    call plug#begin('~/AppData/Local/nvim/plugged')

    " File and folder management
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'preservim/nerdtree'
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

    " Snippets
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'natebosch/dartlang-snippets'
    
    " Vim sarround
    Plug 'tpope/vim-surround'

    " Language support
    Plug 'tpope/vim-projectionist'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'jiangmiao/auto-pairs'
    
    " Dart
    Plug 'dart-lang/dart-vim-plugin'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'vim-airline/vim-airline'

    " Theme
    Plug 'morhetz/gruvbox'
    call plug#end()

    colorscheme gruvbox

    set noerrorbells                                              " Don't add sounds for errors
    set number
    set nowrap
    set nohlsearch
    set smartcase
    set noswapfile
    set nobackup
    set undodir=~/AppData/Local/nvim-data/backup
    set undofile
    set incsearch
    set tabstop=2
    set softtabstop=0 noexpandtab
    set shiftwidth=2
    " set colorcolumn=120
    set clipboard=unnamedplus
    set backspace=indent,eol,start
    " highlight ColorColumn ctermbg=0 guibg=lightgrey

    let mapleader=" "
    nnoremap <leader>fe :CocCommand flutter.emulators <CR>
    nnoremap <leader>fd :below new output:///flutter-dev <CR>
    map <leader>h :wincmd h <CR>
    map <leader>j :wincmd j <CR>
    map <leader>k :wincmd k <CR>
    map <leader>l :wincmd l <CR>
    
    noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
    noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')
    
    inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
    inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))
    
    " imap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
    " imap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

    nnoremap <C-b> :NERDTreeToggle<CR>

    let g:dart_format_on_save = 1
    let g:dartfmt_options = ['--fix', '--line-length 120']

    " Coc
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)

    " Use K to show documentation in preview window
    nnoremap <silent> K :call <SID>show_documentation()<CR>
    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
      else
        execute '!' . &keywordprg . " " . expand('<cword>')
      endif
    endfunction

    nmap <C-P> :FZF<CR>

    nmap <leader>gs :G<CR>
    nmap <leader>gh :diffget //2<CR>
    nmap <leader>gl :diffget //3<CR>

    imap <tab> <Plug>(coc-snippets-expand)
    let g:UltiSnipsExpandTrigger = '<Nop>'
    " let g:coc_snippet_next = '<TAB>'
    " let g:coc_snippet_prev = '<S-TAB>'

    " Use <c-space> to trigger completion.
    if has('nvim')
      inoremap <silent><expr> <c-space> coc#refresh()
    else
      inoremap <silent><expr> <c-@> coc#refresh()
    endif

    " Applying codeAction to the selected region.
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a <Plug>(coc-codeaction-selected)
    nmap <leader>a <Plug>(coc-codeaction-selected)
    
    " enable vim auto save
    " let g:auto_save = 1

    "coc config
    let g:coc_global_extensions = [
      \ 'coc-flutter',
      \ 'coc-snippets',
      \ 'coc-yaml',
      \ ]

    let g:NERDTreeGitStatusWithFlags = 1
endif

