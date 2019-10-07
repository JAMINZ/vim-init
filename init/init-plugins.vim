"======================================================================
"
" init-plugins.vim - 
"
" Created by skywind on 2018/05/31
" Last Modified: 2018/06/10 23:11
"
"======================================================================
" vim: set ts=4 sw=4 tw=78 noet :

"----------------------------------------------------------------------
" 默认情况下的分组，可以再前面覆盖之
"----------------------------------------------------------------------
if !exists('g:bundle_group')
	let g:bundle_group = ['basic', 'tags', 'enhanced', 'filetypes', 'textobj']
	let g:bundle_group += ['tags', 'airline', 'nerdtree', 'ale', 'echodoc']
	let g:bundle_group += ['leaderf']
	let g:bundle_group += ['fzf']
	let g:bundle_group += ['old']
	let g:bundle_group += ['ycm']
endif


"----------------------------------------------------------------------
" 计算当前 vim-init 的子路径
"----------------------------------------------------------------------
let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h:h')

function! s:path(path)
	let path = expand(s:home . '/' . a:path )
	return substitute(path, '\\', '/', 'g')
endfunc


"----------------------------------------------------------------------
" 在 ~/.vim/bundles 下安装插件
"----------------------------------------------------------------------
call plug#begin(get(g:, 'bundle_home', '~/.vim/bundles'))


"----------------------------------------------------------------------
" 默认插件 
"----------------------------------------------------------------------

" 全文快速移动，<leader><leader>f{char} 即可触发
Plug 'easymotion/vim-easymotion'

" 文件浏览器，代替 netrw
Plug 'justinmk/vim-dirvish'

" 表格对齐，使用命令 Tabularize
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }

" Diff 增强，支持 histogram / patience 等更科学的 diff 算法
Plug 'chrisbra/vim-diff-enhanced'


"----------------------------------------------------------------------
" Dirvish 设置：自动排序并隐藏文件，同时定位到相关文件
" 这个排序函数可以将目录排在前面，文件排在后面，并且按照字母顺序排序
" 比默认的纯按照字母排序更友好点。
"----------------------------------------------------------------------
function! s:setup_dirvish()
	if &buftype != 'nofile' && &filetype != 'dirvish'
		return
	endif
	if has('nvim')
		return
	endif
	" 取得光标所在行的文本（当前选中的文件名）
	let text = getline('.')
	if ! get(g:, 'dirvish_hide_visible', 0)
		exec 'silent keeppatterns g@\v[\/]\.[^\/]+[\/]?$@d _'
	endif
	" 排序文件名
	exec 'sort ,^.*[\/],'
	let name = '^' . escape(text, '.*[]~\') . '[/*|@=|\\*]\=\%($\|\s\+\)'
	" 定位到之前光标处的文件
	call search(name, 'wc')
	noremap <silent><buffer> ~ :Dirvish ~<cr>
	noremap <buffer> % :e %
endfunc


" refer http://goushi.me/navigation-in-vim/
augroup dirvish_config
    autocmd!

    " Map `t` to open in new tab.
    autocmd FileType dirvish
                \  nnoremap <silent><buffer> t :call dirvish#open('tabedit', 0)<CR>
                \ |xnoremap <silent><buffer> t :call dirvish#open('tabedit', 0)<CR>

    " Map `gr` to reload.
    autocmd FileType dirvish nnoremap <silent><buffer>
                \ gr :<C-U>Dirvish %<CR>

    " Map `gh` to hide dot-prefixed files.  Press `R` to "toggle" (reload).
    autocmd FileType dirvish nnoremap <silent><buffer>
                \ gh :silent keeppatterns g@\v/\.[^\/]+/?$@d _<cr>:setl cole=3<cr>
augroup END

augroup MyPluginSetup
	autocmd!
	autocmd FileType dirvish call s:setup_dirvish()
augroup END


"----------------------------------------------------------------------
" 基础插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'basic') >= 0

	" 展示开始画面，显示最近编辑过的文件
	Plug 'mhinz/vim-startify'

	" 一次性安装一大堆 colorscheme
	Plug 'flazz/vim-colorschemes'

	" 支持库，给其他插件用的函数库
	Plug 'xolox/vim-misc'

	" 用于在侧边符号栏显示 marks （ma-mz 记录的位置）
	Plug 'kshenoy/vim-signature'

	" 用于在侧边符号栏显示 git/svn 的 diff
	Plug 'mhinz/vim-signify'

	" 根据 quickfix 中匹配到的错误信息，高亮对应文件的错误行
	" 使用 :RemoveErrorMarkers 命令或者 <space>ha 清除错误
	Plug 'mh21/errormarker.vim'

	" 使用 ALT+e 会在不同窗口/标签上显示 A/B/C 等编号，然后字母直接跳转
	Plug 't9md/vim-choosewin'

	" 提供基于 TAGS 的定义预览，函数参数预览，quickfix 预览
	Plug 'skywind3000/vim-preview'

	" Git 支持
	Plug 'tpope/vim-fugitive'

	" 使用 ALT+E 来选择窗口
	nmap <m-e> <Plug>(choosewin)

	" 默认不显示 startify
	let g:startify_disable_at_vimenter = 1
	let g:startify_session_dir = '~/.vim/session'

	" 使用 <space>ha 清除 errormarker 标注的错误
	noremap <silent><space>ha :RemoveErrorMarkers<cr>

	" signify 调优
	let g:signify_vcs_list = ['git', 'svn']
	let g:signify_sign_add               = '+'
	let g:signify_sign_delete            = '_'
	let g:signify_sign_delete_first_line = '‾'
	let g:signify_sign_change            = '~'
	let g:signify_sign_changedelete      = g:signify_sign_change

	" git 仓库使用 histogram 算法进行 diff
	let g:signify_vcs_cmds = {
			\ 'git': 'git diff --no-color --diff-algorithm=histogram --no-ext-diff -U0 -- %f',
			\}
endif


"----------------------------------------------------------------------
" 增强插件
"----------------------------------------------------------------------
if index(g:bundle_group, 'enhanced') >= 0

	" 用 v 选中一个区域后，ALT_+/- 按分隔符扩大/缩小选区
	Plug 'terryma/vim-expand-region'

	" 快速文件搜索
	" Plug 'junegunn/fzf'
	Plug 'junegunn/fzf',{ 'do': './install --all' }
	Plug 'junegunn/fzf.vim'

	" 给不同语言提供字典补全，插入模式下 c-x c-k 触发
	Plug 'asins/vim-dict'

	" 使用 :FlyGrep 命令进行实时 grep
	Plug 'wsdjeg/FlyGrep.vim'

	" 使用 :CtrlSF 命令进行模仿 sublime 的 grep
	Plug 'dyng/ctrlsf.vim'

	" 配对括号和引号自动补全
	Plug 'Raimondi/delimitMate'

	" 提供 gist 接口
	Plug 'lambdalisue/vim-gista', { 'on': 'Gista' }
	
	" ALT_+/- 用于按分隔符扩大缩小 v 选区
	map <m-=> <Plug>(expand_region_expand)
	map <m--> <Plug>(expand_region_shrink)
endif

" ============================================================================
" FZF {{{
" The function the same as LeaderF.
" ============================================================================
" refer this config from github: junegunn/dotfiles
"  fzf.vim
if index(g:bundle_group, 'fzf') >= 0
	nnoremap <silent> <Leader>C        :Colors<CR>
	nnoremap <silent> <Leader>b  	   :Buffers<CR>
	nnoremap <silent> <Leader>f 	   :Files<CR>
	nnoremap <silent> <Leader>l        :Lines<CR>
	nnoremap <silent> <Leader>ag       :Ag <C-R><C-W><CR>
	nnoremap <silent> <Leader>AG       :Ag <C-R><C-A><CR>
	xnoremap <silent> <Leader>ag       y:Ag <C-R>"<CR>
	nnoremap <silent> <Leader>`        :Marks<CR>


	nmap <Leader>f :Files<CR>
	nmap <Leader>F :GFiles<CR>
	nmap <Leader>b :Buffers<CR>
	nmap <Leader>h :History<CR>
	nmap <Leader>t :BTags<CR>
	nmap <Leader>T :Tags<CR>
	nmap <Leader>l :BLines<CR>
	nmap <Leader>L :Lines<CR>
	nmap <Leader>' :Marks<CR>
	nmap <Leader>: :History:<CR>
	" nmap <Leader>/ :History/<CR>

	" 因为ripgrep是目前性能最好的文本内容搜索工具，所以我们可以自己定义一个命令
	command! -bang -nargs=* Rg
	  \ call fzf#vim#grep(
	  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
	  \   <bang>0 ? fzf#vim#with_preview('up:60%')
	  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
	  \   <bang>0)


	" Mapping selecting mappings
	nmap <leader><tab> <plug>(fzf-maps-n)
	xmap <leader><tab> <plug>(fzf-maps-x)
	omap <leader><tab> <plug>(fzf-maps-o)

	" " Insert mode completion
	imap <c-x><c-k> <plug>(fzf-complete-word)
	imap <c-x><c-f> <plug>(fzf-complete-path)
	imap <c-x><c-j> <plug>(fzf-complete-file-ag)
	imap <c-x><c-l> <plug>(fzf-complete-line)

	" Advanced customization using autoload functions
	inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})


	" -------------------- {
	" 上面的命令都可以通过ctrl-t, ctrl-x, ctrl-v来在new tab, new split, new vsplit窗口打开
	" This is the default extra key bindings
	let g:fzf_action = {
	  \ 'ctrl-t': 'tab split',
	  \ 'ctrl-x': 'split',
	  \ 'ctrl-v': 'vsplit' }

	" Default fzf layout
	" - down / up / left / right
	let g:fzf_layout = { 'down': '~40%' }

	" In Neovim, you can set up fzf window using a Vim command
	let g:fzf_layout = { 'window': 'enew' }
	let g:fzf_layout = { 'window': '-tabnew' }
	let g:fzf_layout = { 'window': '10split enew' }

	" Customize fzf colors to match your color scheme
	let g:fzf_colors =
	\ { 'fg':      ['fg', 'Normal'],
	  \ 'bg':      ['bg', 'Normal'],
	  \ 'hl':      ['fg', 'Comment'],
	  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
	  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
	  \ 'hl+':     ['fg', 'Statement'],
	  \ 'info':    ['fg', 'PreProc'],
	  \ 'border':  ['fg', 'Ignore'],
	  \ 'prompt':  ['fg', 'Conditional'],
	  \ 'pointer': ['fg', 'Exception'],
	  \ 'marker':  ['fg', 'Keyword'],
	  \ 'spinner': ['fg', 'Label'],
	  \ 'header':  ['fg', 'Comment'] }

	" Enable per-command history.
	" CTRL-N and CTRL-P will be automatically bound to next-history and
	" previous-history instead of down and up. If you don't like the change,
	" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.

	let g:fzf_history_dir = '~/.local/share/fzf-history'
	" --------------------}



	function! s:testfzf()
	" -------------------- {
	if has('nvim') || has('gui_running')
	  let $FZF_DEFAULT_OPTS .= ' --inline-info'
	endif

	" Hide statusline of terminal buffer
	autocmd! FileType fzf
	autocmd  FileType fzf set laststatus=0 noshowmode noruler
	  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

	let g:fzf_colors =
	\ { 'fg':      ['fg', 'Normal'],
	  \ 'bg':      ['bg', 'Normal'],
	  \ 'hl':      ['fg', 'Comment'],
	  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
	  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
	  \ 'hl+':     ['fg', 'Statement'],
	  \ 'info':    ['fg', 'PreProc'],
	  \ 'border':  ['fg', 'Ignore'],
	  \ 'prompt':  ['fg', 'Conditional'],
	  \ 'pointer': ['fg', 'Exception'],
	  \ 'marker':  ['fg', 'Keyword'],
	  \ 'spinner': ['fg', 'Label'],
	  \ 'header':  ['fg', 'Comment'] }

	command! -bang -nargs=? -complete=dir Files
	  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

	" nnoremap <silent> <Leader><Leader> :Files<CR>
	nnoremap <silent> <expr> <Leader><Leader> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : '').":Files\<cr>"
	nnoremap <silent> <Leader>C        :Colors<CR>
	nnoremap <silent> <Leader><Enter>  :Buffers<CR>
	nnoremap <silent> <Leader>L        :Lines<CR>
	command! -bang -nargs=* Ag
	  \ call fzf#vim#ag(<q-args>,
	  \                 <bang>0 ? fzf#vim#with_preview('up:60%')
	  \                         : fzf#vim#with_preview('right:50%:hidden', '?'),
	  \                 <bang>0)
	nnoremap <silent> <Leader>ag       :Ag <C-R><C-W><CR>
	nnoremap <silent> <Leader>AG       :Ag <C-R><C-A><CR>
	xnoremap <silent> <Leader>ag       y:Ag <C-R>"<CR>
	nnoremap <silent> <Leader>`        :Marks<CR>
	" nnoremap <silent> q: :History:<CR>
	" nnoremap <silent> q/ :History/<CR>

	inoremap <expr> <c-x><c-t> fzf#complete('tmuxwords.rb --all-but-current --scroll 500 --min 5')
	imap <c-x><c-k> <plug>(fzf-complete-word)
	imap <c-x><c-f> <plug>(fzf-complete-path)
	inoremap <expr> <c-x><c-d> fzf#vim#complete#path('blsd')
	imap <c-x><c-j> <plug>(fzf-complete-file-ag)
	imap <c-x><c-l> <plug>(fzf-complete-line)

	" nmap <leader><tab> <plug>(fzf-maps-n)
	" xmap <leader><tab> <plug>(fzf-maps-x)
	" omap <leader><tab> <plug>(fzf-maps-o)

	function! s:plug_help_sink(line)
	  let dir = g:plugs[a:line].dir
	  for pat in ['doc/*.txt', 'README.md']
		let match = get(split(globpath(dir, pat), "\n"), 0, '')
		if len(match)
		  execute 'tabedit' match
		  return
		endif
	  endfor
	  tabnew
	  execute 'Explore' dir
	endfunction

	command! PlugHelp call fzf#run(fzf#wrap({
	  \ 'source': sort(keys(g:plugs)),
	  \ 'sink':   function('s:plug_help_sink')}))
	" -------------------- }
	endfunction


endif
" }}}

"----------------------------------------------------------------------
" 自动生成 ctags/gtags，并提供自动索引功能
" 不在 git/svn 内的项目，需要在项目根目录 touch 一个空的 .root 文件
" 详细用法见：https://zhuanlan.zhihu.com/p/36279445
"----------------------------------------------------------------------
if index(g:bundle_group, 'tags') >= 0

	" 提供 ctags/gtags 后台数据库自动更新功能
	Plug 'ludovicchabant/vim-gutentags'

	" 提供 GscopeFind 命令并自动处理好 gtags 数据库切换
	" 支持光标移动到符号名上：<leader>cg 查看定义，<leader>cs 查看引用
	Plug 'skywind3000/gutentags_plus'

	" 设定项目目录标志：除了 .git/.svn 外，还有 .root 文件]
	" let g:gutentags_project_root = ['.git','.root','.svn','.hg','.project']
	let g:gutentags_project_root = ['.root']
	let g:gutentags_ctags_tagfile = '.tags'

	" 默认生成的数据文件集中到 ~/.cache/tags 避免污染项目目录，好清理
	let g:gutentags_cache_dir = expand('~/.cache/tags')

	" 默认禁用自动生成
	let g:gutentags_modules = [] 

	" 如果有 ctags 可执行就允许动态生成 ctags 文件
	if executable('ctags')
		let g:gutentags_modules += ['ctags']
	endif

	" 如果有 gtags 可执行就允许动态生成 gtags 数据库
	if executable('gtags') && executable('gtags-cscope')
		let g:gutentags_modules += ['gtags_cscope']
	endif

	" 设置 ctags 的参数
	let g:gutentags_ctags_extra_args = []
	let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
	let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
	let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

	" 使用 universal-ctags 的话需要下面这行，请反注释
	let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

	" 禁止 gutentags 自动链接 gtags 数据库
	let g:gutentags_auto_add_gtags_cscope = 0

	" change focus to quickfix window after search (optional)
	let g:gutentags_plus_switch = 1

	" disable the default keymaps 
	let g:gutentags_plus_nomap = 1

	" default keymap
	"<leader>cs    Find symbol (reference) under cursor
	"<leader>cg    Find symbol definition under cursor
	"<leader>cd    Functions called by this function
	"<leader>cc    Functions calling this function
	"<leader>ct    Find text string under cursor
	"<leader>ce    Find egrep pattern under cursor
	"<leader>cf    Find file name under cursor
	"<leader>ci    Find files #including the file name under cursor
	"<leader>ca    Find places where current symbol is assigned

	" define my new maps
	noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>
	noremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>
	noremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>
	noremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>
	noremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>
	noremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
	noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
	noremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>
	noremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>

	"----------vim-preview配置-----------------------------------------
	"P 预览 大p关闭
	autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
	autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>
	noremap <Leader>u :PreviewScroll -1<cr> " 往上滚动预览窗口
	noremap <Leader>d :PreviewScroll +1<cr> "  往下滚动预览窗口

endif


"----------------------------------------------------------------------
" 文本对象：textobj 全家桶
"----------------------------------------------------------------------
if index(g:bundle_group, 'textobj') >= 0

	" 基础插件：提供让用户方便的自定义文本对象的接口
	Plug 'kana/vim-textobj-user'

	" indent 文本对象：ii/ai 表示当前缩进，vii 选中当缩进，cii 改写缩进
	Plug 'kana/vim-textobj-indent'

	" 语法文本对象：iy/ay 基于语法的文本对象
	Plug 'kana/vim-textobj-syntax'

	" 函数文本对象：if/af 支持 c/c++/vim/java
	Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }

	" 参数文本对象：i,/a, 包括参数或者列表元素
	Plug 'sgur/vim-textobj-parameter'

	" 提供 python 相关文本对象，if/af 表示函数，ic/ac 表示类
	Plug 'bps/vim-textobj-python', {'for': 'python'}

	" 提供 uri/url 的文本对象，iu/au 表示
	Plug 'jceb/vim-textobj-uri'
endif


"----------------------------------------------------------------------
" 文件类型扩展
"----------------------------------------------------------------------
if index(g:bundle_group, 'filetypes') >= 0

	" powershell 脚本文件的语法高亮
	Plug 'pprovost/vim-ps1', { 'for': 'ps1' }

	" lua 语法高亮增强
	Plug 'tbastos/vim-lua', { 'for': 'lua' }

	" C++ 语法高亮增强，支持 11/14/17 标准
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for': ['c', 'cpp'] }

	" 额外语法文件
	Plug 'justinmk/vim-syntax-extra', { 'for': ['c', 'bison', 'flex', 'cpp'] }

	" python 语法文件增强
	Plug 'vim-python/python-syntax', { 'for': ['python'] }

	" rust 语法增强
	Plug 'rust-lang/rust.vim', { 'for': 'rust' }

	" vim org-mode 
	Plug 'jceb/vim-orgmode', { 'for': 'org' }
endif


"----------------------------------------------------------------------
" airline
"----------------------------------------------------------------------
if index(g:bundle_group, 'airline') >= 0
	Plug 'vim-airline/vim-airline'
	Plug 'vim-airline/vim-airline-themes'
	let g:airline_left_sep = ''
	let g:airline_left_alt_sep = ''
	let g:airline_right_sep = ''
	let g:airline_right_alt_sep = ''
	let g:airline_powerline_fonts = 0
	let g:airline_exclude_preview = 1
	let g:airline_section_b = '%n'
	let g:airline_theme='deus'
	let g:airline#extensions#branch#enabled = 0
	let g:airline#extensions#syntastic#enabled = 0
	let g:airline#extensions#fugitiveline#enabled = 0
	let g:airline#extensions#csv#enabled = 0
	let g:airline#extensions#vimagit#enabled = 0
endif


"----------------------------------------------------------------------
" NERDTree
"----------------------------------------------------------------------
if index(g:bundle_group, 'nerdtree') >= 0
	Plug 'scrooloose/nerdtree', {'on': ['NERDTree', 'NERDTreeFocus', 'NERDTreeToggle', 'NERDTreeCWD', 'NERDTreeFind'] }
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
	let g:NERDTreeMinimalUI = 1
	let g:NERDTreeDirArrows = 1
	let g:NERDTreeHijackNetrw = 0
	noremap <space>nn :NERDTree<cr>
	noremap <space>no :NERDTreeFocus<cr>
	noremap <space>nm :NERDTreeMirror<cr>
	noremap <space>nt :NERDTreeToggle<cr>
endif


"----------------------------------------------------------------------
" LanguageTool 语法检查
"----------------------------------------------------------------------
if index(g:bundle_group, 'grammer') >= 0
	Plug 'rhysd/vim-grammarous'
	noremap <space>rg :GrammarousCheck --lang=en-US --no-move-to-first-error --no-preview<cr>
	map <space>rr <Plug>(grammarous-open-info-window)
	map <space>rv <Plug>(grammarous-move-to-info-window)
	map <space>rs <Plug>(grammarous-reset)
	map <space>rx <Plug>(grammarous-close-info-window)
	map <space>rm <Plug>(grammarous-remove-error)
	map <space>rd <Plug>(grammarous-disable-rule)
	map <space>rn <Plug>(grammarous-move-to-next-error)
	map <space>rp <Plug>(grammarous-move-to-previous-error)
endif


"----------------------------------------------------------------------
" ale：动态语法检查
"----------------------------------------------------------------------
if index(g:bundle_group, 'ale') >= 0
	Plug 'w0rp/ale'

	" 设定延迟和提示信息
	let g:ale_completion_delay = 500
	let g:ale_echo_delay = 20
	let g:ale_lint_delay = 500
	let g:ale_echo_msg_format = '[%linter%] %code: %%s'

	" 设定检测的时机：normal 模式文字改变，或者离开 insert模式
	" 禁用默认 INSERT 模式下改变文字也触发的设置，太频繁外，还会让补全窗闪烁
	let g:ale_lint_on_text_changed = 'normal'
	let g:ale_lint_on_insert_leave = 1

	" 在 linux/mac 下降低语法检查程序的进程优先级（不要卡到前台进程）
	if has('win32') == 0 && has('win64') == 0 && has('win32unix') == 0
		let g:ale_command_wrapper = 'nice -n5'
	endif

	" 允许 airline 集成
	let g:airline#extensions#ale#enabled = 1

	" 编辑不同文件类型需要的语法检查器
	let g:ale_linters = {
				\ 'c': ['gcc', 'cppcheck'], 
				\ 'cpp': ['gcc', 'cppcheck'], 
				\ 'python': ['flake8', 'pylint'], 
				\ 'lua': ['luac'], 
				\ 'go': ['go build', 'gofmt'],
				\ 'java': ['javac'],
				\ 'javascript': ['eslint'], 
				\ }


	" 获取 pylint, flake8 的配置文件，在 vim-init/tools/conf 下面
	function s:lintcfg(name)
		let conf = s:path('tools/conf/')
		let path1 = conf . a:name
		let path2 = expand('~/.vim/linter/'. a:name)
		if filereadable(path2)
			return path2
		endif
		return shellescape(filereadable(path2)? path2 : path1)
	endfunc

	" 设置 flake8/pylint 的参数
	let g:ale_python_flake8_options = '--conf='.s:lintcfg('flake8.conf')
	let g:ale_python_pylint_options = '--rcfile='.s:lintcfg('pylint.conf')
	let g:ale_python_pylint_options .= ' --disable=W'
	let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
	let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
	let g:ale_c_cppcheck_options = ''
	let g:ale_cpp_cppcheck_options = ''

	let g:ale_linters.text = ['textlint', 'write-good', 'languagetool']

	" 如果没有 gcc 只有 clang 时（FreeBSD）
	if executable('gcc') == 0 && executable('clang')
		let g:ale_linters.c += ['clang']
		let g:ale_linters.cpp += ['clang']
	endif
endif


"----------------------------------------------------------------------
" echodoc：搭配 YCM/deoplete 在底部显示函数参数
"----------------------------------------------------------------------
if index(g:bundle_group, 'echodoc') >= 0
	Plug 'Shougo/echodoc.vim'
	set noshowmode
	let g:echodoc#enable_at_startup = 1
endif


"----------------------------------------------------------------------
" LeaderF：CtrlP / FZF 的超级代替者，文件模糊匹配，tags/函数名 选择
"----------------------------------------------------------------------
if index(g:bundle_group, 'leaderf') >= 0
	" 如果 vim 支持 python 则启用  Leaderf
	if has('python') || has('python3')
		Plug 'Yggdroot/LeaderF'

		" CTRL+p 打开文件模糊匹配
		let g:Lf_ShortcutF = '<c-p>'

		" ALT+n 打开 buffer 模糊匹配
		let g:Lf_ShortcutB = '<m-n>'
		" let g:Lf_ShortcutB = '<c-b>'
		" let g:Lf_ShortcutB = '<C-f>b'

		" CTRL+n 打开最近使用的文件 MRU，进行模糊匹配
		noremap <c-n> :LeaderfMru<cr>

		" ALT+p 打开函数列表，按 i 进入模糊匹配，ESC 退出
		noremap <m-p> :LeaderfFunction!<cr>

		" ALT+SHIFT+p 打开 tag 列表，i 进入模糊匹配，ESC退出
		noremap <m-P> :LeaderfBufTag!<cr>

		" ALT+n 打开 buffer 列表进行模糊匹配
		noremap <m-n> :LeaderfBuffer<cr>

		" 全局 tags 模糊匹配
		noremap <m-m> :LeaderfTag<cr>

		" 最大历史文件保存 2048 个
		let g:Lf_MruMaxFiles = 2048

		" -------------------- {
		" refer http://goushi.me/navigation-in-vim/
		" let g:Lf_ShortcutF = '<C-f>p'
		" let g:Lf_ShortcutB = '<C-f>b'
		" noremap <C-f>u :LeaderfMru<CR>
		" noremap <C-f>f :LeaderfFunction!<CR>
		" noremap <C-f>t :LeaderfTag<CR>
		" noremap <C-f>l :LeaderfLine<CR>
		" noremap <C-f>c :LeaderfHistoryCmd<CR>
		" noremap <C-f>s :LeaderfHistorySearch<CR>
		" noremap <C-f>h :LeaderfHelp<CR>
		" noremap <Leader>fm :LeaderfMru<cr>
		noremap <Leader>fc :LeaderfHistoryCmd<CR>
		noremap <Leader>fl :LeaderfLine<cr>
 
		" -------------------- }

		" ui 定制
		let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

		" 如何识别项目目录，从当前文件目录向父目录递归知道碰到下面的文件/目录
		" let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
		let g:Lf_RootMarkers = ['.root']
		let g:Lf_WorkingDirectoryMode = 'Ac'
		let g:Lf_WindowHeight = 0.30
		let g:Lf_CacheDirectory = expand('~/.vim/cache')

		" 显示绝对路径
		let g:Lf_ShowRelativePath = 0

		" 隐藏帮助
		let g:Lf_HideHelp = 1

		" 模糊匹配忽略扩展名
		let g:Lf_WildIgnore = {
					\ 'dir': ['.svn','.git','.hg'],
					\ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
					\ }

		" MRU 文件忽略扩展名
		let g:Lf_MruFileExclude = ['*.so', '*.exe', '*.py[co]', '*.sw?', '~$*', '*.bak', '*.tmp', '*.dll']
		let g:Lf_StlColorscheme = 'powerline'

		" 禁用 function/buftag 的预览功能，可以手动用 p 预览
		let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

		" 使用 ESC 键可以直接退出 leaderf 的 normal 模式
		let g:Lf_NormalMap = {
				\ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
				\ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<cr>']],
				\ "Mru": [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<cr>']],
				\ "Tag": [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<cr>']],
				\ "BufTag": [["<ESC>", ':exec g:Lf_py "bufTagExplManager.quit()"<cr>']],
				\ "Function": [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<cr>']],
				\ }

	else
		" 不支持 python ，使用 CtrlP 代替
		Plug 'ctrlpvim/ctrlp.vim'

		" 显示函数列表的扩展插件
		Plug 'tacahiroy/ctrlp-funky'

		" 忽略默认键位
		let g:ctrlp_map = ''

		" 模糊匹配忽略
		let g:ctrlp_custom_ignore = {
		  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
		  \ 'file': '\v\.(exe|so|dll|mp3|wav|sdf|suo|mht)$',
		  \ 'link': 'some_bad_symbolic_links',
		  \ }

		" 项目标志
		let g:ctrlp_root_markers = ['.project', '.root', '.svn', '.git']
		let g:ctrlp_working_path = 0

		" CTRL+p 打开文件模糊匹配
		noremap <c-p> :CtrlP<cr>

		" CTRL+n 打开最近访问过的文件的匹配
		noremap <c-n> :CtrlPMRUFiles<cr>

		" ALT+p 显示当前文件的函数列表
		noremap <m-p> :CtrlPFunky<cr>

		" ALT+n 匹配 buffer
		noremap <m-n> :CtrlPBuffer<cr>
	endif
endif


" ============================================================================
" 快速注释
" nerdcommenter {{{
" ============================================================================
if index(g:bundle_group, 'old') >= 0
	Plug 'scrooloose/nerdcommenter'

	 " 注释的时候自动加个空格, 强迫症必配
	 let g:NERDSpaceDelims=1


	Plug 'vim-scripts/Mark--Karkat'
	nmap <Leader>M <Plug>MarkToggle 
	" nmap <Leader><SPACE> <Plug>MarkAllClear
	" nmap <Leader>MM <Plug>MarkAllClear
	nmap ,<SPACE> <Plug>MarkAllClear

	Plug 'jremmen/vim-ripgrep'
	Plug 'mileszs/ack.vim'

	Plug 'majutsushi/tagbar'
	map <f10> :TagbarToggle<cr>
	inoremap <silent> <F10> <esc> :TagbarToggle<cr>
	" inoremap <silent> <leader>t <esc> :TagbarToggle<cr>
endif
" }}}

" ============================================================================
" 自动补全插件YCM
" YouCompleteMe {{{
" ============================================================================
if index(g:bundle_group, 'ycm') >= 0
	Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer',
            \ 'for': ['s', 'S', 'c', 'h', 'C', 'cpp', 'cc', 'cxx', 'py', 'go', 'java', 'js', 'php', 'sh', 'conf', 'vimrc', 'bashrc', 'config', 'ini'] }

endif
" }}}




"----------------------------------------------------------------------
" 结束插件安装
"----------------------------------------------------------------------
call plug#end()


if 0
"----------------------------------------------------------------------
" YouCompleteMe 默认设置：YCM 需要你另外手动编译安装
"----------------------------------------------------------------------

" 禁用预览功能：扰乱视听
let g:ycm_add_preview_to_completeopt = 0

" 禁用诊断功能：我们用前面更好用的 ALE 代替
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings=1
let g:ycm_key_invoke_completion = '<c-z>'
set completeopt=menu,menuone,noselect

" noremap <c-z> <NOP>
endif

if 1
" ============================================================================
" YouCompleteMe.vim {{{
" ============================================================================
" 补全配置脚本 
" function! s:ycm_test()
let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'

" 弹出列表时选择第1项的快捷键(默认为<TAB>和<Down>)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
" 弹出列表时选择前1项的快捷键(默认为<S-TAB>和<UP>)
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
" 主动补全, 默认为<C-Space>
let g:ycm_key_invoke_completion = '<C-x>'
" 停止显示补全列表(防止列表影响视野),可以按<C-x>重新弹出
let g:ycm_key_list_stop_completion = ['<C-y>']

" 停止提示是否载入本地ycm_extra_conf文件
let g:ycm_confirm_extra_conf = 0

let g:ycm_seed_identifiers_with_syntax = 1
" 开启YCM 基于标签引擎
let g:ycm_collect_identifiers_from_tags_files = 1
" 从第2个键入字符就开始罗列匹配项
let g:ycm_min_num_of_chars_for_completion = 2
" 开启输入注释时补全
let g:ycm_complete_in_comments = 1
" 开启输入字符串时补全
let g:ycm_complete_in_strings = 1
" 开启注释和字符串中收集补全
let g:ycm_collect_identifiers_from_comments_and_strings = 1
" 关闭函数预览
let g:ycm_add_preview_to_completeopt = 0
" 关闭代码诊断
let g:ycm_show_diagnostics_ui = 0
" 设置标识符补全最小字符数
let g:ycm_min_num_identifier_candidate_chars = 2
" 设置以下语言自动弹出语义补全(默认需要输入'.->::'或者按主动补全组合键)

endif

" 两个字符自动触发语义补全
let g:ycm_semantic_triggers =  {
			\ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
			\ 'cs,lua,javascript': ['re!\w{2}'],
			\ }


"----------------------------------------------------------------------
" Ycm 白名单（非名单内文件不启用 YCM），避免打开个 1MB 的 txt 分析半天
"----------------------------------------------------------------------
let g:ycm_filetype_whitelist = { 
			\ "c":1,
			\ "cpp":1, 
			\ "objc":1,
			\ "objcpp":1,
			\ "python":1,
			\ "java":1,
			\ "javascript":1,
			\ "coffee":1,
			\ "vim":1, 
			\ "go":1,
			\ "cs":1,
			\ "lua":1,
			\ "perl":1,
			\ "perl6":1,
			\ "php":1,
			\ "ruby":1,
			\ "rust":1,
			\ "erlang":1,
			\ "asm":1,
			\ "nasm":1,
			\ "masm":1,
			\ "tasm":1,
			\ "asm68k":1,
			\ "asmh8300":1,
			\ "asciidoc":1,
			\ "basic":1,
			\ "vb":1,
			\ "make":1,
			\ "cmake":1,
			\ "html":1,
			\ "css":1,
			\ "less":1,
			\ "json":1,
			\ "cson":1,
			\ "typedscript":1,
			\ "haskell":1,
			\ "lhaskell":1,
			\ "lisp":1,
			\ "scheme":1,
			\ "sdl":1,
			\ "sh":1,
			\ "zsh":1,
			\ "bash":1,
			\ "man":1,
			\ "markdown":1,
			\ "matlab":1,
			\ "maxima":1,
			\ "dosini":1,
			\ "conf":1,
			\ "config":1,
			\ "zimbu":1,
			\ "ps1":1,
			\ }

" ============================================================================
" Quickfix {{{
" ============================================================================
"Quickfix
nmap <leader>cd :cn<cr>
nmap <leader>cp :cp<cr>
nmap <leader>cw :botright copen<cr>
nmap <leader>cq :cclose<cr>
nmap <leader>lq :lclose<cr>
nmap <leader>rg :Rgrep<cr>
" nmap <leader>gc :G /\<<c-r>=expand("<cword>")<cr>\>/<cr>
" nmap <leader>ga :Grep /\<<c-r>=expand("<cword>")<cr>\><cr>
nmap <leader>cb :botright cwindow<cr>

nmap <leader>qo :QFix<CR>

nmap <leader>ft :call QFixToggle(1)<CR>
command! -bang -nargs=? QFix call QFixToggle(<bang>0)
 
function! QFixToggle(forced)
    if exists("g:qfix_win") && a:forced != 0
        cclose
    else
        if exists("g:my_quickfix_win_height")
            execute "copen ".g:my_quickfix_win_height
        else
            botright copen
        endif
    endif
endfunction
 
augroup QFixToggle
    autocmd!
    autocmd BufWinEnter quickfix let g:qfix_win = bufnr("$")
    autocmd BufWinLeave * if exists("g:qfix_win") && expand("<abuf>") == g:qfix_win | unlet! g:qfix_win | endif
augroup END
" }}}


" ============================================================================
" ack {{{
" ============================================================================
let g:ackprg = 'ag --nogroup --nocolor --column'
nnoremap <leader>F :Ack<space>

" }}}


