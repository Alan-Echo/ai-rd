# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this AI R&D 工作区。

## 这是什么

这是 Alan-Ark 项目的 AI 研发团队工作区。它把真实研发流程（需求评审 → 技术方案 → 技术评审 → 开发 → Code Review → QA → 产品验收 → 发布）映射到 Claude Code 的 subagent + skill 能力上。

工作区**只保存研发过程产物**（需求 / 架构 / 契约 / 决策 / 任务 / 评审 / 测试 / 验收），**绝不复制业务代码**。代码只存在于三个业务仓库。

## 三个业务仓库

| 角色      | 路径                                     | 技术栈                          | git                                       |
| ------- | -------------------------------------- | ---------------------------- | ----------------------------------------- |
| backend | `G:/Workspace/Alan-Ark/alan-ark`       | Spring Boot 多模块 Maven        | ✓                                         |
| admin   | `G:/Workspace/Alan-Ark/alan-ark-admin` | Vue 3 + Vite + pnpm + UnoCSS | ✓                                         |
| app     | `G:/Workspace/Alan-Ark/alan-ark-app`   | uni-app + uniCloud           | ✗（未 git init） |

路径以 `projects/alan-ark/project.yaml` 为准，**禁止猜测**。

## 团队（8 个角色，定义在 `.claude/agents/`）

team-lead · product · tech-lead · backend · admin · app · reviewer · qa

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

- **先决策、后编码**：未过需求 + 技术评审，禁止修改三个业务仓库
- 绝不修改三个仓库的生产代码（除非进入开发且门禁通过）
- 禁止直接改 main/master；用 `feature/<requirement>/<component>` 分支或 worktree
- 危险操作（force push / reset --hard / 删分支 / 删数据）必须先询问
- 不把推测当事实：扫描结论标注 `CONFIRMED / INFERRED / UNKNOWN`

## 如何发起一个需求

1. 以 team-lead 身份启动：`/team-lead`（或主会话按 team-lead 职责工作）
2. team-lead 创建 `REQ-xxx` → 组织需求评审 → `APPROVED`
3. tech-lead 产出 `ARC-xxx` → 技术评审（含独立 reviewer）→ `APPROVED`
4. 拆 `TASK-xxx` → 派发 backend / admin / app
5. 开发 → reviewer → qa → product 验收 → 人工发布确认

## 产物目录

`projects/alan-ark/` 下：`requirements/` `architecture/` `contracts/` `decisions/` `tasks/` `reviews/` `tests/` `acceptance/` `meetings/`（模板见各目录 `_template.md`）。

## 其他

- 本工作区所有 agent 共用全局模型（DeepSeek `deepseek-v4-pro[1m]`），不区分 haiku/sonnet/opus。
- hooks / 权限 / MCP 在 `.claude/settings.json` 与全局配置层管理，不在单个 agent 文件内声明（subagent 不继承这些）。
