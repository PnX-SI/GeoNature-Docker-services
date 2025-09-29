#!/usr/bin/env bash
# submodules_apply_preflight_v4.sh
# Fix: do NOT overwrite PATH env var (use SM_PATH instead).
set -euo pipefail
shopt -s extglob

CONF="${CONF:-submodules.env}"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"
COMMIT="${COMMIT:-0}"
COMMIT_MSG="${COMMIT_MSG:-chore(submodules): update pointers}"
DRY_FETCH="${DRY_FETCH:-1}"
LOG_LEVEL="${LOG_LEVEL:-info}"

info()  { printf 'info: %s\n' "$*"; }
warn()  { printf 'WARN: %s\n' "$*" >&2; }
error() { printf 'ERROR: %s\n' "$*" >&2; }
debug() { [ "$LOG_LEVEL" = "debug" ] && printf 'debug: %s\n' "$*"; return 0; }

run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry] %s\n' "$*"
  else
    printf '+ %s\n' "$*"
    eval "$@"
  fi
}

trim() {
  local s="${1-}"
  s="${s//$'\r'/}"            # strip CR
  s="${s##+([[:space:]])}"    # ltrim
  s="${s%%+([[:space:]])}"    # rtrim
  printf '%s' "$s"
}

parse_ref() {
  case "$1" in
    branch:*)          echo "branch ${1#branch:}";;
    tag:*)             echo "tag ${1#tag:}";;
    sha:*|commit:*)    echo "commit ${1#*:}";;
    *)                 echo "commit $1";;
  esac
}

submodule_name_by_path() {
  local target="$1" k v name
  while IFS= read -r line; do
    k="${line%% *}" ; v="${line#* }"
    case "$k" in
      submodule.*.path)
        name="${k#submodule.}"; name="${name%.path}"
        if [ "$v" = "$target" ]; then printf '%s' "$name"; return 0; fi
        ;;
    esac
  done < <(git config -f .gitmodules --get-regexp '^submodule\..*\.path' 2>/dev/null || true)
  return 1
}

gitmodules_value() { git config -f .gitmodules "$1" 2>/dev/null || true; }
registered_by_name() { git config -f .gitmodules --name-only --get-regexp "^submodule\\.$1\\." >/dev/null 2>&1; }
is_repo() { git -C "$1" rev-parse --is-inside-work-tree >/dev/null 2>&1; }
is_gitlink() {
  git ls-files --stage -- "$1" | awk '$1==160000{found=1} END{exit (found?0:1)}'
}


is_dirty() {
  git -C "$1" update-index -q --refresh || true
  ! git -C "$1" diff --quiet --ignore-submodules=all && return 0
  ! git -C "$1" diff --cached --quiet --ignore-submodules=all && return 0
  [ -n "$(git -C "$1" ls-files --other --exclude-standard)" ] && return 0
  return 1
}

short_sha() { git -C "$1" rev-parse --short HEAD 2>/dev/null || true; }

current_desc() {
  local p="$1"
  if ! is_repo "$p"; then echo "-"; return; fi
  local b; b="$(git -C "$p" symbolic-ref --short -q HEAD || true)"
  local sha; sha="$(short_sha "$p")"
  if [ -n "$b" ]; then
    echo "branch:$b @ $sha"
  else
    local t; t="$(git -C "$p" describe --tags --exact-match 2>/dev/null || true)"
    if [ -n "$t" ]; then
      echo "tag:$t @ $sha"
    else
      echo "detached @ $sha"
    fi
  fi
}

check_remote_ref_exists() {
  local type="$1" val="$2" sm_path="$3" url="$4"
  if [ "$DRY_FETCH" != "1" ]; then
    printf 'unknown (DRY_FETCH=0)\n'; return 0
  fi
  case "$type" in
    branch)
      if is_repo "$sm_path"; then
        git -C "$sm_path" ls-remote --heads origin "$val" >/dev/null 2>&1
      else
        git ls-remote --heads "$url" "$val" >/dev/null 2>&1
      fi
      case $? in 0) echo "yes";; 2) echo "no";; *) echo "unreachable";; esac
      ;;
    tag)
      if is_repo "$sm_path"; then
        git -C "$sm_path" ls-remote --tags origin "refs/tags/$val" >/dev/null 2>&1
      else
        git ls-remote --tags "$url" "refs/tags/$val" >/dev/null 2>&1
      fi
      case $? in 0) echo "yes";; 2) echo "no";; *) echo "unreachable";; esac
      ;;
    commit)
      if is_repo "$sm_path" && git -C "$sm_path" cat-file -e "$val^{commit}" 2>/dev/null; then
        echo "yes (local)"
      else
        echo "unknown (needs fetch to verify)"
      fi
      ;;
  esac
  return 0
}

list_dirty_files() {
  local p="$1"
  echo "  • STAGED:";   git -C "$p" diff --name-status --cached || true
  echo "  • UNSTAGED:"; git -C "$p" diff --name-status || true
  echo "  • UNTRACKED:";git -C "$p" ls-files --other --exclude-standard || true
}

ensure_registered() {
  local name="$1" sm_path="$2" url="$3" type="$4" val="$5"
  if ! registered_by_name "$name"; then
    local existing; existing="$(submodule_name_by_path "$sm_path" || true)"
    if [ -n "${existing:-}" ] && [ "$existing" != "$name" ]; then
      warn "PATH '$sm_path' déjà référencé dans .gitmodules sous '$existing' (≠ '$name')."
    fi
    if [ "$DRY_RUN" = "1" ]; then
      if [ "$type" = "branch" ]; then
        echo "[dry] git submodule add -b $val --name $name $url $sm_path"
      else
        echo "[dry] git submodule add --name $name $url $sm_path"
      fi
    else
      if [ "$type" = "branch" ]; then
        run git submodule add -b "$val" --name "$name" "$url" "$sm_path"
      else
        run git submodule add --name "$name" "$url" "$sm_path"
      fi
    fi
  else
    local cur_url; cur_url="$(gitmodules_value "submodule.$name.url")"
    local cur_path; cur_path="$(gitmodules_value "submodule.$name.path")"
    if [ "$cur_url" != "$url" ]; then
      if [ "$DRY_RUN" = "1" ]; then
        echo "[dry] update .gitmodules url for $name → $url ; submodule sync"
      else
        run git config -f .gitmodules "submodule.$name.url" "$url"
        run git submodule sync -- "$sm_path"
      fi
    fi
    if [ "$cur_path" != "$sm_path" ] && [ -n "$cur_path" ]; then
      warn ".gitmodules path for $name = '$cur_path' ≠ '$sm_path' (env)."
    fi
    if ! is_repo "$sm_path"; then
      if [ "$DRY_RUN" = "1" ]; then
        echo "[dry] would initialize/clone $sm_path"
      else
        run git submodule update --init -- "$sm_path"
      fi
    fi
  fi
}

checkout_ref() {
  local sm_path="$1" type="$2" val="$3"
  run git -C "$sm_path" fetch --tags --prune
  case "$type" in
    branch) run git -C "$sm_path" checkout -B "$val" "origin/$val" ;;
    tag)    run git -C "$sm_path" checkout --detach "refs/tags/$val" \
                     || run git -C "$sm_path" checkout --detach "$val" ;;
    commit) run git -C "$sm_path" checkout --detach "$val" ;;
  esac
}

already_on_ref() {
  local sm_path="$1" type="$2" val="$3"
  case "$type" in
    branch)
      local cur; cur="$(git -C "$sm_path" symbolic-ref --short -q HEAD || true)"
      [ "$cur" = "$val" ]
      ;;
    tag)
      local want head
      want="$(git -C "$sm_path" rev-parse -q --verify "refs/tags/$val" || true)"
      head="$(git -C "$sm_path" rev-parse HEAD)"
      [ -n "$want" ] && [ "$head" = "$want" ]
      ;;
    commit)
      [ "$(git -C "$sm_path" rev-parse HEAD)" = "$val" ]
      ;;
  esac
}

root="$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$(pwd)")"
info "root     : $root"
info "pwd      : $(pwd)"
info "conf     : $CONF  (DRY_RUN=$DRY_RUN FORCE=$FORCE COMMIT=$COMMIT LOG_LEVEL=$LOG_LEVEL DRY_FETCH=$DRY_FETCH)"
printf '\n'

line_no=0
summary_lines=()

while IFS= read -r raw || [ -n "$raw" ]; do
  line_no=$((line_no+1))
  [ -z "${raw//[[:space:]]/}" ] && continue
  [[ "$raw" =~ ^[[:space:]]*# ]] && continue

  IFS='|' read -r NAME SM_PATH URL REF <<<"$raw"
  NAME="$(trim "${NAME:-}")"
  SM_PATH="$(trim "${SM_PATH:-}")"
  URL="$(trim "${URL:-}")"
  REF="$(trim "${REF:-}")"

  if [ -z "$NAME" ] || [ -z "$SM_PATH" ] || [ -z "$URL" ] || [ -z "$REF" ]; then
    error "$CONF:$line_no → format NAME|PATH|URL|REF"
    exit 1
  fi

  read -r TYPE VAL < <(parse_ref "$REF")

  printf '=== %s\n' "$NAME"
  printf '  path    : %s\n' "$SM_PATH"
  printf '  url     : %s\n' "$URL"
  printf '  target  : %s:%s\n' "$TYPE" "$VAL"

  local_reg='no'; registered_by_name "$NAME" && local_reg='yes'
  printf '  reg'\''d   : %s\n' "$local_reg"
  found_by_path="$(submodule_name_by_path "$SM_PATH" || true)"
  if [ -n "$found_by_path" ] && [ "$found_by_path" != "$NAME" ]; then
    warn "PATH '$SM_PATH' déjà enregistré sous le nom '$found_by_path' (différent de '$NAME')."
  fi

  local_init='no'
  is_repo "$SM_PATH" && local_init='yes'
  printf '  init    : %s\n' "$local_init"
  if [ "$local_init" = "yes" ]; then
    printf '  gitlink : %s\n' "$(is_gitlink "$SM_PATH" && echo yes || echo no)"
    printf '  current : %s\n' "$(current_desc "$SM_PATH")"
    if is_dirty "$SM_PATH"; then
      echo "  dirty   : yes"
      list_dirty_files "$SM_PATH"
      local_dirty='yes'
    else
      echo "  dirty   : no"
      local_dirty='no'
    fi
  else
    local_dirty='-'
  fi

  printf '  remote  : '
  remote_state="$(check_remote_ref_exists "$TYPE" "$VAL" "$SM_PATH" "$URL" || true)"
  printf '%s\n' "$remote_state"

  action_msg=""
  if [ "$DRY_RUN" = "1" ]; then
    if [ "$local_init" = "no" ]; then
      action_msg="would add/init and checkout $TYPE:$VAL"
    else
      if [ "$local_dirty" = "yes" ] && [ "$FORCE" != "1" ]; then
        action_msg="SKIP (dirty; run with FORCE=1 to override)"
      else
        if already_on_ref "$SM_PATH" "$TYPE" "$VAL"; then
          if [ "$TYPE" = "branch" ]; then
            action_msg="already on $TYPE:$VAL (would fetch/reset to origin/$VAL)"
          else
            action_msg="already on $TYPE:$VAL"
          fi
        else
          action_msg="would checkout $TYPE:$VAL"
        fi
      fi
    fi
    printf '  action  : %s\n\n' "$action_msg"
    summary_lines+=("$NAME|$action_msg|init:$local_init|dirty:$local_dirty|remote:$remote_state")
    continue
  fi

  ensure_registered "$NAME" "$SM_PATH" "$URL" "$TYPE" "$VAL"
  if ! is_repo "$SM_PATH"; then
    error "$SM_PATH non initialisé."
    exit 1
  fi

  if [ "$local_dirty" = "yes" ] && [ "$FORCE" != "1" ]; then
    warn "SKIP $NAME: modifications locales détectées (utilisez FORCE=1 pour forcer)."
    summary_lines+=("$NAME|SKIP (dirty)|init:yes|dirty:yes|remote:$remote_state")
    printf '\n'
    continue
  fi

  if already_on_ref "$SM_PATH" "$TYPE" "$VAL"; then
    info "$NAME: déjà sur $TYPE:$VAL"
    if [ "$TYPE" = "branch" ]; then
      run git -C "$SM_PATH" fetch --prune
      run git -C "$SM_PATH" reset --hard "origin/$VAL" || true
    fi
    summary_lines+=("$NAME|ok (already)|init:yes|dirty:$local_dirty|remote:$remote_state")
  else
    info "$NAME: checkout $TYPE:$VAL"
    checkout_ref "$SM_PATH" "$TYPE" "$VAL"
    summary_lines+=("$NAME|ok (checked out)|init:yes|dirty:$local_dirty|remote:$remote_state")
  fi

  printf '\n'
done < "$CONF"

if [ "$DRY_RUN" = "0" ] && [ "$COMMIT" = "1" ] && [ "${#summary_lines[@]}" -gt 0 ]; then
  info "Commit des pointeurs de sous-modules…"
  while IFS='|' read -r _path; do
    run git add "$_path"
  done < <(awk -F'|' '{print $1}' <<< "$(printf '%s\n' "${summary_lines[@]}")") || true
  if git diff --cached --name-only | grep -q '^.gitmodules$'; then run git add .gitmodules; fi
  run git commit -m "$COMMIT_MSG" || info "Rien à committer."
fi

printf '\nSummary:\n'
printf '  %-28s | %-34s | %-10s | %-10s | %-12s\n' "NAME" "ACTION" "INIT" "DIRTY" "REMOTE"
printf '  %s\n' "----------------------------------------------------------------------------------------------------------"
for s in "${summary_lines[@]}"; do
  IFS='|' read -r n a i d r <<<"$s"
  printf '  %-28s | %-34s | %-10s | %-10s | %-12s\n' "$n" "$a" "${i#init:}" "${d#dirty:}" "${r#remote:}"
done

exit 0
