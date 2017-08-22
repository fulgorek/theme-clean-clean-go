# Status Chars
set __fish_git_prompt_char_dirtystate '✖︎'
set __fish_git_prompt_char_untrackedfiles ' new!'
set __fish_git_prompt_char_stashstate 'stash'
set __fish_git_prompt_char_cleanstate '●'

# Display the state of the branch when inside of a git repo
function __cc_go_parse_git_branch_state -d "Display the state of the branch"
  git update-index --really-refresh -q 1> /dev/null

  # Check for changes to be commited
  if git_is_touched
    set_color red
    echo -n "$__fish_git_prompt_char_dirtystate"
  else
    set_color green
    echo -n "$__fish_git_prompt_char_cleanstate"
  end

  # Check for untracked files
  set -l git_untracked (command git ls-files --others --exclude-standard 2> /dev/null)
  if [ -n "$git_untracked" ]
    echo -n "$__fish_git_prompt_char_untrackedfiles"
  end

  # Check for stashed files
  if git_is_stashed
    echo -n "$__fish_git_prompt_char_stashstate"
  end

  # Check if branch is ahead, behind or diverged of remote
  git_ahead
end

# Display current git branch
function __cc_go_git -d "Display the actual git branch"
  set -l ref
  set -l std_prompt (prompt_pwd)
  set -l is_dot_git (string match '*/.git' $std_prompt)

  if git_is_repo; and test -z $is_dot_git
    printf 'on git:'

    set -l git_branch (command git symbolic-ref --quiet --short HEAD 2> /dev/null; or git rev-parse --short HEAD 2> /dev/null; or echo -n '(unknown)')
    set_color cyan
    printf '%s ' $git_branch

    set state (__cc_go_parse_git_branch_state)
    printf '%s' $state

    set_color normal
  end
end

# Print current user
function __cc_go_get_user -d "Print the user"
  if test $USER = 'root'
    set_color --bold red
  else
    set_color cyan
  end
  printf '%s' (whoami)
end

# Get Machines Hostname
function __cc_go_get_host -d "Get Hostname"
  if test $SSH_TTY
    tput bold
    set_color red
  else
    set_color af8700
  end
  printf '%s' (hostname|cut -d . -f 1)
end

# Get Project Working Directory
function __cc_go_pwd -d "Get PWD"
  set_color --bold yellow
  printf '[%s] ' (echo $PWD | sed -e "s|^$HOME|~|")
end

# fxone-prompt
function fish_prompt
  set -l code $status

  # Logged in user
  __cc_go_get_user
  set_color normal

  printf ' in '

  # Path
  __cc_go_pwd
  set_color normal

  # Git info
  __cc_go_git

  # Line 2
  echo

  set_color --bold red

  printf '→ '
  set_color normal
end
