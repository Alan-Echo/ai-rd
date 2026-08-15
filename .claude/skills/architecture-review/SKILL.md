---
name: architecture-review
description: 技术方案评审。评审架构文档（ARC）的正确性、可行性、风险。技术评审时使用。
---

# 技术评审（Architecture Review）

## 参加者
Tech Lead / Backend / Admin / App / Reviewer（复杂需求加 Security / Database / Performance）

## 评审维度
- 是否满足已批准需求
- 模块划分是否合理、跨仓库影响是否清晰
- 数据模型 / API 变更是否完整
- 安全、性能、兼容性、迁移是否考虑
- 风险与回滚方案是否可行

## 输出
ARC 文档 status = APPROVED / CHANGES_REQUIRED
- CHANGES_REQUIRED → 回退 ARCHITECTURE_DESIGN

## 原则
方案作者不能是唯一审批人。
