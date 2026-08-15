---
name: requirement-review
description: 需求评审标准流程。评审需求文档（REQ）的完整性、业务规则、异常流程、验收标准。需要评审需求或澄清需求时使用。
---

# 需求评审（Requirement Review）

## 评审目标
确保需求完整、无歧义、可验收、可落地，明确业务边界。

## 检查清单
- [ ] Business Goal 明确，能回答"为什么做"
- [ ] User Story 完整，覆盖核心用户
- [ ] User Flow 覆盖主流程 + 异常流程
- [ ] Business Rules 无歧义（不能靠"按常规"推断）
- [ ] Edge Cases 已列举
- [ ] Acceptance Criteria 可验证、可量化
- [ ] Open Questions 已标注（未决问题不允许进入开发）
- [ ] Impacted Systems 明确（Backend / Admin / App 谁受影响）

## 输出
会议 decision：APPROVED / REJECTED / NEED_INFO
- NEED_INFO → 回退需求澄清，补充后重新评审

## 禁止
需求未明确时直接进入技术方案或开发。
