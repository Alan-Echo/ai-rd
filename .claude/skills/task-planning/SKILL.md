---
name: task-planning
description: 任务拆解。将已批准的架构拆解为可派发的开发任务（TASK）。拆解开发任务时使用。
---

# 任务拆解（Task Planning）

## 前置
REQUIREMENT_APPROVED 且 ARCHITECTURE_APPROVED 之后才能拆解开发任务。

## 拆解原则
- 按仓库拆分：backend / admin / app 各自独立任务
- 每个 TASK 明确：Repository、Requirement、Architecture、Contract、Scope、Non Scope、Dependencies、Acceptance Criteria、Test Requirements
- 标注依赖关系（如 admin / app 依赖 backend 的 Contract 先行）
- 三个 agent 不修改同一仓库的同一业务区域

## 输出
tasks/TASK-xxx.md，status = READY
