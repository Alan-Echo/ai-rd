# AI R&D Team — 使用手册

> Claude Code 多 Agent 协作研发团队 + 多分支交付体系

## 目录

1. [这是什么](#1-这是什么)
2. [系统架构](#2-系统架构)
3. [前置条件](#3-前置条件)
4. [快速开始](#4-快速开始)
5. [接到新项目（核心流程）](#5-接到新项目核心流程)
6. [与团队协作](#6-与团队协作)
7. [常用命令速查](#7-常用命令速查)
8. [收尾归档](#8-收尾归档)
9. [团队规范更新](#9-团队规范更新)
10. [故障排查](#10-故障排查)
11. [已验证清单](#11-已验证清单)

---

## 1. 这是什么

把真实软件研发流程（**需求评审 → 技术方案 → 技术评审 → 开发 → Code Review → QA → 产品验收 → 发布**）映射到 Claude Code **Agent Teams** 能力的多 Agent 协作系统。

- **8 个角色**：team-lead（唯一协调者）、product、tech-lead、backend、admin、app、reviewer、qa
- **Agent Teams 模式**：team-lead 通过 `subagent_type` 拉起各角色作为 teammates，teammate 之间可 SendMessage 协作
- **多分支交付**：每个交付项目 = 4 个仓库（ai-rd + 三端）的**同名分支 + 同名 worktree**

## 2. 系统架构

```
G:\Workspace\Alan-Ark\              ← 主干（各仓库 main，只读基线）
├── ai-rd\                          ← AI R&D 团队工作区（git: github.com/Alan-Echo/ai-rd）
│   ├── CLAUDE.md                   ← 团队规则（状态机/门禁/信息优先级）
│   ├── .claude\agents\             ← 8 个 agent 定义
│   ├── .claude\skills\             ← 7 个 skill
│   ├── .claude\settings.json       ← 权限 + Agent Teams 开关
│   ├── scripts\create-delivery.sh  ← 一键建交付项目
│   └── projects\alan-ark\          ← 产物模板 + current-system.md（系统扫描）
├── alan-ark\                       ← backend（Spring Boot 4 + MyBatis-Plus + Sa-Token）
├── alan-ark-admin\                 ← admin（Vue 3 + Vite + pnpm）
└── alan-ark-app\                   ← app（uni-app x，需 HBuilderX 构建）

G:\Workspace\projects\<项目名>\     ← 交付项目（4 仓库同名分支 + worktree）
├── ai-rd\                          ← 项目专属团队 + 产物
├── alan-ark\                       ← backend @ <项目名>
├── alan-ark-admin\                 ← admin @ <项目名>
└── alan-ark-app\                   ← app @ <项目名>
```

**核心原则**：
- 工作区（ai-rd）只存产物/agent/skill，**绝不复制业务代码**
- 代码只存在三个业务仓库
- `main` 永远只读基线，开发都在交付分支 + worktree 里

## 3. 前置条件

- Claude Code **v2.1.232+**（支持 Agent Teams）
- 四个仓库已 git init 并推送远程：
  - `ai-rd` → `github.com/Alan-Echo/ai-rd`
  - 三端各自远程
- 主干仓库在 `G:\Workspace\Alan-Ark\` 下
- 后端为 DeepSeek（`deepseek-v4-pro[1m]`，配置在全局 `~/.claude/settings.json`）

## 4. 快速开始

```bash
# 确保团队最新（首次或隔段时间）
cd G:/Workspace/Alan-Ark/ai-rd
git pull
```

然后直接看下一节"接到新项目"。

## 5. 接到新项目（核心流程）

### ① 创建交付项目（建分支 + worktree）

```bash
cd G:/Workspace/Alan-Ark/ai-rd
./scripts/create-delivery.sh wechat-push
```

- 默认三端都建；只要部分端：`./scripts/create-delivery.sh wechat-push backend admin`
- 预览不执行：加 `--dry-run`；从远程拉最新 main：加 `--pull`

执行后，4 个仓库各多一个 `wechat-push` 分支 + 一个 worktree 到 `G:\Workspace\projects\wechat-push\`。

### ② 进入项目专属团队

```bash
cd G:/Workspace/projects/wechat-push/ai-rd
claude --agent team-lead --add-dir ../alan-ark ../alan-ark-admin ../alan-ark-app
```

> 注意：用 `--agent team-lead` 让会话本身就是 team-lead，**不是** `/team-lead` 斜杠命令。
> `--add-dir` 让 teammates 能跨目录访问三个仓库。

### ③ 直接描述需求

进去后会话已是 team-lead，直接说：

```
我要做「微信消息推送」，涉及后端 + 管理端 + App 三端
```

## 6. 与团队协作

team-lead 会按状态机推进，各阶段产出对应 Artifact：

```
发起需求
  → team-lead 建 REQ → 需求评审(product/backend/admin/app/tech-lead) → APPROVED
  → tech-lead 建 ARC + Contract → 技术评审(含 reviewer) → APPROVED
  → 拆 TASK → 并行派发 backend/admin/app（各自在 worktree 开发）
  → reviewer 评审 → qa 测试 → product 验收 → RELEASE_PENDING
  → 人工确认 → 合并回 main
```

**开发 agent 的行为**：backend/admin/app 会先读各自仓库的 `CLAUDE.md` + `docs/` 规范（这是写进 agent 的第 0 步），再动手，保证代码风格/架构约束对齐项目。

## 7. 常用命令速查

| 操作 | 命令 |
|---|---|
| 建交付项目 | `./scripts/create-delivery.sh <名> [backend admin app] [--dry-run] [--pull]` |
| 进入团队 | `claude --agent team-lead --add-dir ../alan-ark ../alan-ark-admin ../alan-ark-app` |
| 单独启动某 agent | `claude --agent backend "实现反馈 API"` |
| 预览建项目 | `./scripts/create-delivery.sh xxx --dry-run` |
| 同步团队更新到进行中项目 | 在项目 ai-rd worktree 里 `git merge main` |

## 8. 收尾归档

```bash
# ① 三个代码仓：分支合并回 main（在主干目录操作）
cd G:/Workspace/Alan-Ark/alan-ark        && git checkout main && git merge wechat-push
cd G:/Workspace/Alan-Ark/alan-ark-admin  && git checkout main && git merge wechat-push
cd G:/Workspace/Alan-Ark/alan-ark-app    && git checkout main && git merge wechat-push

# ② 删 worktree（ai-rd 的分支不 merge，留作项目归档）
git -C G:/Workspace/Alan-Ark/ai-rd          worktree remove G:/Workspace/projects/wechat-push/ai-rd
git -C G:/Workspace/Alan-Ark/alan-ark       worktree remove G:/Workspace/projects/wechat-push/alan-ark
git -C G:/Workspace/Alan-Ark/alan-ark-admin worktree remove G:/Workspace/projects/wechat-push/alan-ark-admin
git -C G:/Workspace/Alan-Ark/alan-ark-app   worktree remove G:/Workspace/projects/wechat-push/alan-ark-app
```

> **合并不对称**：代码仓的分支 merge 回 main（代码进主干）；ai-rd 的分支**不 merge**（保持 main 纯团队），只留作项目归档。

## 9. 团队规范更新

- **改团队**（agent/skill/模板）只在 `ai-rd` 的 `main` 上改，push
- **已在进行的项目要同步**：在项目 ai-rd worktree 里 `git merge main`
- 团队是"快照"：改 main 不会自动同步到进行中的项目，这是特性（进行中项目保持稳定）

## 10. 故障排查

| 现象 | 原因 | 解决 |
|---|---|---|
| `/team-lead` 报 Unknown command | 自定义 agent 不是斜杠命令 | 用 `claude --agent team-lead` |
| teammate 跨目录读不到 | `--add-dir` 没加或路径错 | 确认三个 `../` 路径齐全 |
| `[unrecognized_model] deepseek-v4-pro[1m]` 警告 | DeepSeek 模型名 `[1m]` 后缀未识别 | 非致命，忽略（只影响标题生成） |
| worktree 建失败 | 项目目录已存在 | 删掉旧目录或换项目名 |
| 分支没从最新 main 拉 | 主干没 pull | 先 `git pull` 或用 `--pull` |

## 11. 已验证清单

| 能力 | 状态 |
|---|---|
| agent 人格加载（`--agent backend` / `--agent team-lead`） | ✅ 已验证 |
| team-lead 拉起 teammate（backend/admin） | ✅ 已验证 |
| teammate 跨目录访问兄弟仓库 | ✅ 已验证 |
| 多 teammate 并行 + team-lead 汇总 | ✅ 已验证 |
| 完整流程（需求 → 发布）端到端 | ⚠️ 待真实项目验证 |
