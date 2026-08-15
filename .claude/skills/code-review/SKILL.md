---
name: code-review
description: 代码评审。评审代码变更是否符合需求/架构/契约。Code Review 时使用。
---

# 代码评审（Code Review）

## 输入
Requirement / Architecture / Contract / Decision / Git Diff / Tests

## 检查维度
需求符合性 / 架构符合性 / API 契约 / 安全 / 并发 / 数据一致性 /
异常处理 / 性能 / 可维护性 / 测试覆盖

## 结论分级
- BLOCKER：必须回退开发
- MAJOR：强烈建议修复
- MINOR：可选
- SUGGESTION：建议

## 输出
reviews/REVIEW-xxx.md，结论 APPROVED / CHANGES_REQUIRED

## 约束
Reviewer 必须独立于 Developer（不能评审自己写的代码）。
