#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# create-delivery.sh — 一键创建交付项目（4 仓库同名分支 + git worktree）
#
# 用法:
#   ./create-delivery.sh <项目名> [组件...] [--dry-run] [--pull]
#
# 例:
#   ./create-delivery.sh wechat-push                    # 默认三端 backend/admin/app
#   ./create-delivery.sh wechat-push backend admin      # 只做后端 + 管理端
#   ./create-delivery.sh wechat-push --dry-run          # 只打印将执行的命令，不真正执行
#   ./create-delivery.sh wechat-push --pull             # 以 origin/main 为分支起点
#
# 约定:
#   - 主干仓库在 TRUNK_DIR 下（ai-rd + alan-ark + alan-ark-admin + alan-ark-app）
#   - 交付项目在 PROJECTS_DIR/<项目名>/ 下，子目录名与仓库名一致
#     （ai-rd / alan-ark / alan-ark-admin / alan-ark-app），与 project.yaml 的
#      相对路径 ../alan-ark 等严格对应
#   - 四个仓库使用同一个分支名 <项目名>，从 main 拉出
# =============================================================================

TRUNK_DIR="G:/Workspace/Alan-Ark"
PROJECTS_DIR="G:/Workspace/projects"
BASE_BRANCH="main"

# 组件名 → 仓库目录名（子目录名与仓库名一致）
repo_dir_for() {
  case "$1" in
    backend) echo "alan-ark" ;;
    admin)   echo "alan-ark-admin" ;;
    app)     echo "alan-ark-app" ;;
    *)       echo "" ;;
  esac
}

PROJECT="${1:?用法: create-delivery.sh <项目名> [组件...] [--dry-run] [--pull]}"
shift

DRY_RUN=false
PULL=false
COMPONENTS=()
for a in "$@"; do
  case "$a" in
    --dry-run) DRY_RUN=true ;;
    --pull)    PULL=true ;;
    *)         COMPONENTS+=("$a") ;;
  esac
done
[ ${#COMPONENTS[@]} -eq 0 ] && COMPONENTS=(backend admin app)

PROJECT_PATH="$PROJECTS_DIR/$PROJECT"

echo "===== 创建交付项目: $PROJECT ====="
echo "主干目录:   $TRUNK_DIR"
echo "项目目录:   $PROJECT_PATH"
echo "组件:       ${COMPONENTS[*]}"
echo "dry-run:    $DRY_RUN    pull: $PULL"
echo

run() {
  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] $*"
  else
    echo "  → $*"
    "$@"
  fi
}

# 项目目录存在性检查（非 dry-run 时）
if [ "$DRY_RUN" != true ] && [ -e "$PROJECT_PATH" ]; then
  echo "!! 项目目录已存在: $PROJECT_PATH" >&2
  echo "!! 若确定重来，请先手动删除该目录。" >&2
  exit 1
fi

run mkdir -p "$PROJECTS_DIR"

# 一个仓库：可选 fetch + 建 worktree（子目录名 = 仓库名）
create_one() {
  local repo_dir="$1"      # 仓库目录名（主干与项目子目录同名）
  local full_repo="$TRUNK_DIR/$repo_dir"
  local target="$PROJECT_PATH/$repo_dir"

  [ -d "$full_repo/.git" ] || { echo "!! 主干仓库不存在: $full_repo" >&2; exit 1; }

  local base_ref="$BASE_BRANCH"   # 默认本地 main
  if [ "$PULL" = true ]; then
    run git -C "$full_repo" fetch origin "$BASE_BRANCH"
    base_ref="origin/$BASE_BRANCH"
  fi

  run git -C "$full_repo" worktree add -b "$PROJECT" "$target" "$base_ref"
}

TOTAL=$(( ${#COMPONENTS[@]} + 1 ))
echo "[1/$TOTAL] ai-rd"
create_one "ai-rd"

i=1
for comp in "${COMPONENTS[@]}"; do
  i=$((i+1))
  repo_dir="$(repo_dir_for "$comp")"
  [ -n "$repo_dir" ] || { echo "!! 未知组件: $comp（可选 backend/admin/app）" >&2; exit 1; }
  echo "[$i/$TOTAL] $comp ($repo_dir)"
  create_one "$repo_dir"
done

echo
echo "===== 完成 ====="
echo "项目目录: $PROJECT_PATH"
echo
echo "下一步:"
echo "  cd \"$PROJECT_PATH/ai-rd\" && claude"
echo "  # 进入后以 /team-lead 发起需求；代码在各仓库 worktree 下开发"
