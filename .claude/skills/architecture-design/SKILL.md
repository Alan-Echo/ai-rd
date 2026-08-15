---
name: architecture-design
description: 技术方案设计。产出架构文档（ARC），涵盖模块划分、数据模型、API、安全、性能、迁移、回滚。设计技术方案时使用。
---

# 技术方案设计（Architecture Design）

## 产出 ARC 文档必须包含
Context / Goals / Non Goals / Current Architecture / Proposed Architecture /
Module Changes / Database Changes / API Changes / Security / Performance /
Compatibility / Migration / Error Handling / Observability / Risks /
Alternatives Considered / Impacted Repositories / Rollback Plan / Status

## 原则
- 输入必须是已批准的需求（REQUIREMENT_APPROVED）
- 跨仓库功能必须优先定义 API Contract
- 明确每个变更落在哪个仓库（backend / admin / app）
- 标注风险与回滚方案

## 禁止
- 在需求未批准时设计架构
- 方案作者自己当唯一审批人（必须独立 Review）
