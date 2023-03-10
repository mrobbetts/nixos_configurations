{ pkgs }:
{
  enable = true;
  autosuggestions.enable = true;
  interactiveShellInit = ''
    # Import our li'l git helper.
    source ${pkgs.zsh-git-prompt}/share/zsh-git-prompt/zshrc.sh

    # See these guys in ~/git/zsh-git-prompt/zshrc.sh
    ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{»%G%}"
    ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[yellow]%}%{»%G%}"
    ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
    ZSH_THEME_GIT_PROMPT_SEPARATOR="::"
    ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[white]%}"
    ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[white]%}%{⚑%G%}"
    ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}%{∉%G%}"

    # History
    source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down

    # Needed for any prompt substitution to work.
    setopt prompt_subst

    # Addition for direnv
    eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
  '';
  syntaxHighlighting = {
    enable = true;
    highlighters = [ "main" "brackets" "pattern" ];
    styles = { # Copy fish config. I like fish.
      "builtin" = "fg=27";
      "command" = "fg=27";
      "alias" = "fg=27";
      "default" = "fg=39";
      "path" = "fg=39,underline";
      "unknown-token" = "fg=red,bold";
      "single-hyphen-option" = "fg=39";
      "double-hyphen-option" = "fg=39";
    };
  };
  promptInit = "PROMPT='[%n@%m %(!.%F{red}.%F{green})%~%f $(git_super_status)]%(!.#.$) '";
}
