#!/usr/bin/env bash
set -euo pipefail

# ===================== Debug / helpers =====================
DEBUG="${DEBUG:-0}"
if [[ "$DEBUG" == "1" || "$DEBUG" == "true" ]]; then
  export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-main}(): '
  set -x
fi

log(){ printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*"; }
mask_url(){ printf '%s' "$1" | sed -E 's#(https?://)[^@/]+@#\1***@#'; }
require_cmd(){ command -v "$1" >/dev/null 2>&1 || { echo "ERROR: '$1' not found. PATH=$PATH"; exit 127; }; }
supports_filter(){ git submodule update -h 2>&1 | grep -q -- '--filter'; }

# ===================== Env / options =====================
require_cmd git
log "pwd=$(pwd)"
log "PATH=$PATH"
log "git version: $(git --version 2>&1 || echo 'unknown')"

CONF="${1:-submodules.env}"
[ -f "$CONF" ] || { echo "Config file not found: $CONF"; exit 1; }
log "Using config: $CONF"

# Perf toggles (surchargeables)
JOBS="${JOBS:-8}"
DEPTH="${DEPTH:-1}"               # vide pour désactiver le shallow
FILTER="${FILTER:-blob:none}"     # vide pour désactiver le partial clone
export GIT_LFS_SKIP_SMUDGE="${GIT_LFS_SKIP_SMUDGE:-1}"
export GIT_PROGRESS="${GIT_PROGRESS:-1}"

if ! supports_filter; then
  log "submodule update ne supporte pas --filter → désactivation du partial clone"
  FILTER=""
fi
log "OPTS: JOBS=${JOBS:-?} DEPTH=${DEPTH:-full} FILTER=${FILTER:-none} LFS_SKIP=${GIT_LFS_SKIP_SMUDGE:-unset}"

changed=0
lineno=0

# ===================== PASS 0: Purger .gitmodules =====================
if [ -f .gitmodules ]; then
  declare -A __seen
  while read -r key; do
    name="${key#submodule.}"; name="${name%%.*}"
    if [[ -z "${__seen[$name]:-}" ]]; then
      git config -f .gitmodules --remove-section "submodule.$name" || true
      __seen[$name]=1
    fi
  done < <(git config -f .gitmodules --name-only --get-regexp '^submodule\..*\..*' 2>/dev/null || true)
fi

# ===================== PASS 1: Réécrire .gitmodules =====================
declare -A seen_paths
while IFS= read -r raw || [[ -n "${raw:-}" ]]; do
  lineno=$((lineno+1))
  line="${raw%$'\r'}"
  [[ -z "${line// }" || "$line" =~ ^# ]] && { log "skip line $lineno"; continue; }

  NAME=""; PATH_SM=""; URL=""; REF=""
  IFS='|' read -r NAME PATH_SM URL REF <<< "$line"
  if [[ -z "${NAME:-}" || -z "${PATH_SM:-}" || -z "${URL:-}" || -z "${REF:-}" ]]; then
    echo "Line $lineno malformed: '$line'"; exit 1
  fi
  if [[ -n "${seen_paths[$PATH_SM]:-}" ]]; then
    echo "Duplicate path in config: $PATH_SM (line $lineno)"; exit 1
  fi
  seen_paths[$PATH_SM]=1

  log "L$lineno[write]: NAME='$NAME' PATH='${PATH_SM}' URL='$(mask_url "$URL")' REF='$REF'"
  git config -f .gitmodules "submodule.$NAME.path" "$PATH_SM"
  git config -f .gitmodules "submodule.$NAME.url"  "$URL"
  case "$REF" in
    branch:*)
      BRANCH="${REF#branch:}"
      git config -f .gitmodules "submodule.$NAME.branch" "$BRANCH"
      git config "submodule.$NAME.branch" "$BRANCH" || true
      ;;
    tag:*|sha:*|commit:*)
      git config -f .gitmodules --unset-all "submodule.$NAME.branch" 2>/dev/null || true
      git config --unset-all "submodule.$NAME.branch" 2>/dev/null || true
      ;;
    *) echo "Unknown REF format for $NAME at line $lineno: $REF"; exit 1;;
  esac
  changed=1
done < "$CONF"

git add .gitmodules
git submodule sync --recursive

# ===================== Helpers d'apply =====================
branch_update() {
  local path="$1" url="$2" branch="$3"

  log "Tracking branch: $branch → update to tip (depth=${DEPTH:-full}, filter=${FILTER:-none})"

  # Active partial clone si demandé
  if [ -n "${FILTER:-}" ]; then
    git -C "$path" config remote.origin.promisor true || true
    git -C "$path" config core.partialClone origin || true
    git -C "$path" config remote.origin.partialclonefilter "$FILTER" || true
  fi

  # 0) S'assurer que la branche existe côté remote
  if ! git -C "$path" ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    log "ERREUR: branche '$branch' introuvable sur origin pour $path"
    return 1
  fi

  # 1) tentative standard
  log "CMD(update): git submodule update --init --remote --jobs $JOBS ${DEPTH:+--depth $DEPTH} ${FILTER:+--filter=$FILTER} $path"
  if ! git submodule update --init --remote --jobs "$JOBS" \
        ${DEPTH:+--depth "$DEPTH"} ${FILTER:+--filter="$FILTER"} "$path"; then
    log "update --remote a échoué → fallback fetch/checkout ciblé"
    git -C "$path" init >/dev/null 2>&1 || true
    if ! git -C "$path" remote get-url origin >/dev/null 2>&1; then
      git -C "$path" remote add origin "$url"
    else
      git -C "$path" remote set-url origin "$url"
    fi
    git -C "$path" config remote.origin.fetch "+refs/heads/$branch:refs/remotes/origin/$branch" || true
    git -C "$path" fetch origin "$branch" ${DEPTH:+--depth "$DEPTH"} || git -C "$path" fetch origin "$branch"
  fi

  # 2) *** FORCER le worktree à être sur la branche demandée ***
  # Si la ref distante n'est pas encore là (cas rare), refetch
  git -C "$path" show-ref --verify --quiet "refs/remotes/origin/$branch" || git -C "$path" fetch origin "$branch" || true
  # Attacher la branche locale au tip d'origin/<branch>
  git -C "$path" checkout -B "$branch" --track "origin/$branch" 2>/dev/null \
  || { git -C "$path" branch -f "$branch" "origin/$branch"; git -C "$path" checkout "$branch"; }

  # 3) Log final lisible
  log "After update: $(git -C "$path" rev-parse --abbrev-ref HEAD || echo '?') @ $(git -C "$path" rev-parse --short HEAD || echo '?')"
}


add_submodule_if_missing() {
  local path="$1" url="$2"
  if [ ! -e "$path/.git" ] && [ ! -f "$path/.git" ]; then
    log "git submodule add -f $url $path"
    if ! git submodule add -f "$url" "$path"; then
      local bkp="${path}.bak.$(date +%s)"
      log "Add a échoué (dossier pré-existant non-git) → backup puis retry: $bkp"
      mv "$path" "$bkp"
      git submodule add -f "$url" "$path"
    fi
    changed=1
  fi
}

# Au lieu de "add_submodule_if_missing", utilise :
ensure_submodule_present() {
  local path="$1" url="$2"
  # Si le dossier existe mais n’est pas git, tu as déjà le backup ailleurs dans le script
  # Ici on se contente d'initialiser depuis .gitmodules :
  git submodule sync -- "$path"
  git submodule update --init "$path"
}

# ===================== PASS 2: add / update / checkout =====================
lineno=0
while IFS= read -r raw || [[ -n "${raw:-}" ]]; do
  lineno=$((lineno+1))
  line="${raw%$'\r'}"
  [[ -z "${line// }" || "$line" =~ ^# ]] && continue

  NAME=""; PATH_SM=""; URL=""; REF=""
  IFS='|' read -r NAME PATH_SM URL REF <<< "$line"
  log "L$lineno[apply]: NAME='$NAME' PATH='${PATH_SM}' URL='$(mask_url "$URL")' REF='$REF'"

  # Dossier présent mais non-git → backup/remove
  if [ -e "$PATH_SM" ] && ! git -C "$PATH_SM" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    if [ -z "$(ls -A "$PATH_SM" 2>/dev/null || true)" ]; then
      log "Path exists but empty (non-git) → remove"
      rmdir "$PATH_SM"
    else
      bkp="${PATH_SM}.bak.$(date +%s)"
      log "Backup non-git directory: $PATH_SM -> $bkp"
      mv "$PATH_SM" "$bkp"
    fi
  fi

  # (Ré)ajouter si manquant
  # add_submodule_if_missing "$PATH_SM" "$URL"
  # S’assurer que le worktree du sous-module est présent (sans add)
  ensure_submodule_present "$PATH_SM" "$URL"


  # Sync de l'URL effective
  git submodule sync -- "$PATH_SM"

  case "$REF" in
    branch:*)
      BRANCH="${REF#branch:}"
      branch_update "$PATH_SM" "$URL" "$BRANCH"
      log "After update: $(git -C "$PATH_SM" rev-parse --abbrev-ref HEAD || echo '?') @ $(git -C "$PATH_SM" rev-parse --short HEAD || echo '?')"
      changed=1
      ;;
    tag:*|sha:*|commit:*)
      VAL="${REF#*:}"
      log "Checkout ref: $VAL (depth=${DEPTH:-full})"
      git submodule update --init "$PATH_SM"
      if [[ "$REF" == tag:* ]]; then
        git -C "$PATH_SM" fetch --tags ${DEPTH:+--depth "$DEPTH"} origin "tag $VAL" || git -C "$PATH_SM" fetch --tags
      else
        git -C "$PATH_SM" fetch --tags --quiet || true
        git -C "$PATH_SM" fetch --quiet || true
      fi
      git -C "$PATH_SM" checkout "$VAL"
      log "Now at: $(git -C "$PATH_SM" rev-parse --short HEAD || echo '?')"
      changed=1
      ;;
  esac
done < "$CONF"

# ===================== Finalisation / commit =====================
if [ $changed -eq 1 ]; then
  log "Staging .gitmodules and submodule paths…"
  git add .gitmodules $(awk -F'|' '!/^#/ && NF>=2 {gsub(/\r$/,""); print $2}' "$CONF")
  #TODO: check if necessary to commit . For now I comment this line 
  # git commit -m "Force rewrite .gitmodules from $CONF and sync submodules" || log "Nothing to commit (no changes)"
fi

log "Finalizing: git submodule update --init --recursive --jobs $JOBS"
git submodule update --init --recursive --jobs "$JOBS"
log "Done."
