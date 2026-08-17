# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this AI R&D 工作区。

## 这是什么

这是 Alan-Ark 项目的 AI 研发团队工作区。它把真实研发流程（需求评审 → 技术方案 → 技术评审 → 开发 → Code Review → QA → 产品验收 → 发布）映射到 Claude Code 的 **Agent Teams** 能力上（team-lead 唯一协调 + 各角色作为 teammates）。

工作区**只保存研发过程产物**（需求 / 架构 / 契约 / 决策 / 任务 / 评审 / 测试 / 验收），**绝不复制业务代码**。代码只存在于三个业务仓库。

## 三个业务仓库

| 角色 | 仓库目录 | 技术栈 | git |
|---|---|---|---|
| backend | `alan-ark` | Spring Boot 4.1.0 多模块基座（无业务模块） | ✓ |
| admin | `alan-ark-admin` | Vue 3 + Vite + pnpm 管理后台模板 | ✓ |
| app | `alan-ark-app` | uni-app x 业务 App（当前走 mock） | ✓ |

路径为**相对 `ai-rd` 根目录**（`../alan-ark` 等），以 `projects/alan-ark/project.yaml` 为准，**禁止猜测**。

## 多分支交付模型

一个交付项目 = 四个仓库（ai-rd + 三端）的**同名分支 + 同名 worktree**：

```
G:/Workspace/Alan-Ark/          # 主干（各仓库 main，只读基线）
└── projects/<项目名>/          # 交付项目（各仓库 <项目名> 分支）
    ├── ai-rd/                  # 该项目专属的团队 + 产物
    ├── alan-ark/               # backend @ <项目名>
    ├── alan-ark-admin/         # admin @ <项目名>
    └── alan-ark-app/           # app @ <项目名>
```

- 接到新项目：`./scripts/create-delivery.sh <项目名> [backend admin app] [--dry-run] [--pull]`
- 进入项目团队：`cd G:/Workspace/projects/<项目名>/ai-rd && claude`
- `ai-rd` 的 `main` 只放团队（agent / skill / 模板 / 脚本），**业务产物只存在于各交付分支**。
- 团队更新只改 `main`；交付分支按需 `git merge main` 同步团队（快照模型）。

## 团队（8 个角色，定义在 `.claude/agents/`）

team-lead · product · tech-lead · backend · admin · app · reviewer · qa

运行模式为 **Agent Teams**：team-lead 是唯一协调 Agent，其余角色是 teammates。
- team-lead 用 `subagent_type` 指定每个 teammate 的 Agent Definition（如 `subagent_type="backend"`）
- `subagent_type` 只指定角色定义，不会让 teammate 降级成普通 subagent——teammate 有独立 session / context，且相互间可用 SendMessage 协作
- 禁止 backend / admin / app / reviewer / qa 自行建立第二个 Team

分离铁律：

- **Reviewer ≠ Developer**（评审必须独立）
- **QA ≠ Product**
- **Team Lead 不是万能开发者**，不写业务代码
- 方案作者不能是唯一审批人

## Workflow 状态机

```
NEW → REQUIREMENT_REVIEW → REQUIREMENT_APPROVED
    → ARCHITECTURE_DESIGN → ARCHITECTURE_REVIEW → ARCHITECTURE_APPROVED
    → DEVELOPMENT → CODE_REVIEW → QA → PRODUCT_ACCEPTANCE
    → RELEASE_PENDING → DONE
```

回退：`NEED_INFO → REQUIREMENT_REVIEW`；`CHANGES_REQUIRED → ARCHITECTURE_DESIGN`；`CODE_REVIEW CHANGES_REQUIRED → DEVELOPMENT`；`QA FAIL → DEVELOPMENT`；`ACCEPTANCE REJECTED → DEVELOPMENT`。

## 门禁（硬约束）

1. 只有 `REQUIREMENT_APPROVED` 才进入架构设计
2. 只有 `ARCHITECTURE_APPROVED` 才派发开发任务
3. Code Review / QA / Acceptance 不通过 → 回退开发
4. 生产发布必须人工确认（AI 默认不能生产发布）

## 信息优先级（冲突时）

```
最新 Approved Decision > Approved Architecture > Approved Requirement
                      > Task > Agent 自己推断
```

发现冲突：`STOP → 通知 team-lead → 讨论 → 更新 Artifact`。业务规则 / API / 权限 / 兼容性 / 删除策略不明确时，**提问，不要按"常规"猜测**。

## 铁律

- **先决策、后编码**：未过需求 + 技术评审，禁止修改业务代码
- 绝不修改主干（main）的生产代码——每个交付项目在独立分支 + worktree 里开发
- 危险操作（force push / reset --hard / 删分支 / 删数据）必须先询问
- 不把推测当事实：扫描结论标注 `CONFIRMED / INFERRED / UNKNOWN`

## 如何发起一个需求

1. `./scripts/create-delivery.sh <项目名>` 建分支 + worktree
2. `cd G:/Workspace/projects/<项目名>/ai-rd && claude --add-dir ../alan-ark ../alan-ark-admin ../alan-ark-app`，以 `/team-lead` 启动（`--add-dir` 让 teammates 能访问兄弟仓库）
3. team-lead 创建 `REQ-xxx` → 需求评审 → `APPROVED`
4. tech-lead 产出 `ARC-xxx` → 技术评审（含独立 reviewer）→ `APPROVED`
5. 拆 `TASK-xxx` → 派发 backend / admin / app（在各自 worktree 下开发）
6. 开发 → reviewer → qa → product 验收 → 人工发布确认 → 合并回 main

## 产物目录

`projects/alan-ark/` 下：`requirements/` `architecture/` `contracts/` `decisions/` `tasks/` `reviews/` `tests/` `acceptance/` `meetings/`（模板见各目录 `_template.md`）。

## 其他

- 本工作区所有 agent 共用全局模型（DeepSeek `deepseek-v4-pro[1m]`），不区分 haiku/sonnet/opus。
- hooks / 权限 / MCP 在 `.claude/settings.json` 与全局配置层管理，不在单个 agent 文件内声明（subagent 不继承这些）。
