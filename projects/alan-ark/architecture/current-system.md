---
id: current-system
status: APPROVED
created: 2026-08-15
updated: 2026-08-15
references: []
owner: tech-lead
---

# current-system — Alan-Ark 当前系统扫描

> 由真实仓库扫描生成（2026-08-15）。每个结论标注：
> - **CONFIRMED**：来自代码 / 各仓库 CLAUDE.md 权威自述 / 目录结构，已核实
> - **INFERRED**：合理推断，未经直接验证
> - **UNKNOWN**：未确认
>
> 主要来源：`alan-ark/CLAUDE.md`、`alan-ark-admin/CLAUDE.md`、`alan-ark-app/CLAUDE.md` + 目录扫描。

## 一句话总览（CONFIRMED）

三个仓库当前都是**脚手架 / 模板 / Demo**，**尚未包含 Alan-Ark 业务逻辑**：

| 仓库 | 真实定位 | 技术栈 |
|---|---|---|
| `alan-ark` | Spring Boot 4.1.0 多模块**基座**（无业务模块） | Java 21 / MyBatis-Plus / MySQL / Redis / Sa-Token / Flyway |
| `alan-ark-admin` | Vue3 企业级**管理后台模板** | Vite 8 / TS / Element Plus / UnoCSS / Pinia / Vue Router |
| `alan-ark-app` | uni-app x **业务 App**（Alan-Ark 用户端，已 git init） | .uts / .uvue，登录/消息/个人中心，当前走 mock |

> ⚠️ **进度不齐**：App 已有业务代码，但后端仍是无业务的基座——App 靠 `USE_MOCK=true` 先行，等后端就绪后切换。

---

## Backend — `alan-ark`（Spring Boot 4.1.0 基座）

### 模块结构（CONFIRMED）
5 模块单向依赖、无循环：

```
api-admin(8081) ──→ api-admin-service ──→ module-core
api-client(8080) ──→ api-client-service ──→ module-core
        ↑ api-admin-service 与 api-client-service 物理隔离，禁止互调 ↑
```

### 分层职责（CONFIRMED）
- **api-admin / api-client**：仅 Controller（薄层委派）+ 启动类，不写业务。
- **api-admin-service / api-client-service**：管理端 / 用户端业务逻辑，物理隔离。
- **module-core**：共享数据层 + 技术基础设施（Entity / Mapper / BaseService / Filter / Sa-Token / 工具 / Flyway），不含业务规则。

### Controller / Service / Mapper / Entity / DTO（CONFIRMED）
- 包路径 `com.alan.ark`；顶级包 `com.alan.ark.core`（业务数据）、`com.alan.ark.common`（跨模块共享）。
- Web 层 `com.alan.ark.{admin,client}.api.<域>.controller`；业务层 `...service.<域>`。
- 方向约定：Request（入参）/ DTO（服务间）/ VO（出参）/ Entity（仅 Service/Mapper 层）。**禁止接口用 Map/JSONObject/Object**。
- ORM：MyBatis-Plus 3.5.16（雪花主键、逻辑删除 `deletedFlag`、链式 Lambda 查询，禁手动 new Wrapper）。

### Security（CONFIRMED）
Sa-Token 1.42 + Redis；手机验证码 / 微信授权登录；`@SaCheckPermission` 注解鉴权；双 Token（Access 12h + Refresh 30d 旋转 + 重用检测）。

### Config（CONFIRMED）
- 共享配置 `module-core/src/main/resources/application-shared.yml`（数据源 / Hikari / Redis / Jackson / Actuator / NanoLog）。
- 两个启动模块各自 `application-{dev,staging,prod}.yml`（api-admin:8081、api-client:8080）。
- 生产启动强制校验敏感配置（`ProdSafetyCheck`）。

### Database / Redis / MQ（CONFIRMED）
- **MySQL 8.0**（Flyway 11.4 迁移，脚本在 `module-core/.../db/migration/`，命名 `V<ver>__<desc>.sql`）。
- **Redis 6.0+**（缓存 / Session / 分布式锁 Redisson）。
- **无外部 MQ**（RabbitMQ/Kafka 未在依赖中）；跨服务通信用 **DB 事件表 `sys_async_task` + Quartz 轮询**（每 30s）。
- 对象存储：OSS 多适配（阿里云/腾讯云/MinIO/AWS S3/本地，`@Lazy` 工厂切换）。

### Test（CONFIRMED）
- JUnit 5 + Mockito + AssertJ；方法命名 `should_Xxx_When_Yyy`。
- **ArchUnit 架构约束测试**（`api-admin` 模块 `ArchitectureTest`），CI 强制，违反即构建失败。

### 规范文档（CONFIRMED）
`docs/` 下 16 份规范：module-spec / code-style / logging-spec / database-spec / security-spec / testing-spec / api-spec / cache-spec / concurrency-spec / system-rules / git-workflow / circular-dependency / operations-manual / deployment-guide / architecture-proposal-qa / nginx-config.conf。

### 关键基础设施（CONFIRMED）
TraceId 全链路追踪、Quartz 异步任务分发（Strategy）、跨模块事件（Spring Event 同服务 / DB 事件表跨服务）、Cache-Aside、乐观锁 `@Version`、`@RateLimit` 限流、SPI 路由。

---

## Admin — `alan-ark-admin`（Vue3 管理后台模板）

### 定位（CONFIRMED）
企业级管理后台模板 AlanArkAdmin，纯前端 SPA，后端在 `../alan-ark`。**pnpm**（强制）+ Node `^20.19 || >=22.12`。所有 UI 文本中文。

### 页面结构（CONFIRMED）
`src/views/`：`dashboard` / `login` / `error` / `profile` / `system`。业务页面由后端动态路由下发。

### Router（CONFIRMED）
Hash 模式；`constantRoutes`（login/dashboard/error/profile）+ 后端下发动态路由（`MenuAPI.getRoutes()` → `permission.ts` 守卫 → `addRoute()`），component 字符串解析到 `views/**/*.vue`。

### Store（CONFIRMED）
Pinia setup stores：`user`（登录/权限/刷新）、`permission`（动态路由）、`settings`（主题/布局）、`app`、`tags-view`。

### API（CONFIRMED）
`src/api/<domain>/index.ts` + `types.ts`；axios 单例 `src/utils/request.ts`；响应 `{code,data,msg}`（成功码 `00000`）；`A0230` 刷新重试、`A0231` 跳登录、`A0301` 权限拒绝。

### Components（CONFIRMED）
大量复用组件：`CURD` / `ECharts` / `Upload` / `WangEditor` / `Pagination` / `TableSelect` / `EnumSelect` / `EnumTag` / `CommandPalette` / `ExportDialog` 等。

### UI / 主题（CONFIRMED）
Element Plus + UnoCSS；4 布局模式（left/top/mix/double）；CSS 变量主题；`light`/`dark`/`auto`。

### 权限（CONFIRMED）
RBAC 按钮级 `v-hasPerm` / `v-hasRole` 指令 + `hasPerm()`；`ROLE_ROOT` 绕过。

### 测试（CONFIRMED）
**无测试框架**（无 Vitest/Jest，无 test script）；husky + lint-staged + commitlint。

---

## App — `alan-ark-app`（uni-app x 业务 App）

### 定位（CONFIRMED）
Alan-Ark **用户端 App**，基于 uni-app x。面向终端用户：手机验证码 / 微信登录、消息中心（站内信 + 公告 + 实时推送）、个人中心。**已 git init**（5 个开发提交）。manifest `name=alan-ark-app`（package.json 仍残留 `hello-uniapp-x` 未改名）。

### 技术（CONFIRMED）
- uni-app x：`.uts` 编译为 Kotlin/Swift/ArkTS 原生代码，移动端无 JS runtime；Vue 3 Composition API。
- **无法 CLI 构建**，需 HBuilderX 3.99+。
- 目标平台：Android / iOS / HarmonyOS / 微信小程序 / H5。

### pages（CONFIRMED）
3 Tab（消息 / 首页 / 我的）+ 12 页面：
- `home`(index)、`login`(index)
- `profile`(index / edit / bind / devices)、`settings`(index)
- `notice`(index / detail)、`announcement`(index / detail)、`about`(index)

### 状态管理（CONFIRMED）
`store/` 用 Vue `reactive()`（无 Vuex/Pinia），按业务拆分：`auth.uts`（token/userInfo）、`notice.uts`（unreadCount）、`index.uts`（暗色/品牌/安全区）。

### 网络层（CONFIRMED）
`utils/`：`config.uts`（BASE_URL / **USE_MOCK** / API 常量）、`request.uts`（自动附 `satoken` 头、401 单飞刷新、错误分类、Mock 分发）、`mock.uts`（后端未就绪时的模拟数据）。

### 登录 / 认证（CONFIRMED）
手机验证码 + 微信登录；Sa-Token 兼容（`satoken` 请求头 + access/refresh 双 Token）。图形验证码仍是算术占位（TODO）。

### WebSocket（CONFIRMED）
`composables/useWebSocket.uts`：对接后端 Spring STOMP（`/ws/notification`），CONNECT 带 satoken → SUBSCRIBE `/user/{id}/queue/notifications`；指数退避重连；消息 mute/unmute/security/announcement/export-complete；`uni.$emit` 派发刷新事件。

### platform differences（CONFIRMED）
条件编译 `#ifdef APP-ANDROID / APP-HARMONY / WEB / MP-WEIXIN / VUE3-VAPOR`。

### 测试（UNKNOWN / INFERRED）
新 CLAUDE.md 无测试章节，原 demo 的 Jest 配置疑似在改造中移除；当前以 HBuilderX 手动调试为主。

### 后端对接 TODO（CONFIRMED，来自 App CLAUDE.md）
BASE_URL 替换真实地址、`USE_MOCK` 改 false、微信 appid/鸿蒙包名、mock 响应结构对齐、验证码换 SDK、头像上传 OSS、STOMP 心跳对齐、隐私协议链接。

---

## 结论与对 AI R&D Team 的影响

1. **进度不齐**（CONFIRMED）：App 已有业务代码（登录/消息/个人中心 + WebSocket + mock），后端仍是无业务的基座，管理端是模板。App 靠 `USE_MOCK=true` 先行，等后端就绪后切换。
2. **后端落地路径**（CONFIRMED）：新业务域需遵循 ArchUnit 约束——Controller 薄层在 api-admin/api-client，业务在 `*-service`，Entity/Mapper 在 module-core，入参 Request/出参 VO。
3. **管理端落地路径**（CONFIRMED）：`views/` 加页面 + `api/<域>/` 加接口模块，复用现有组件。
4. **App 已定**（CONFIRMED）：已由官方 Demo 改造成业务 App 并 git init，worktree 隔离可用。
5. **真实设计文档在 `../.design/`**（CONFIRMED）：`app端设计/`、`后端架构设计/`（12 份）、`UI设计/`，做需求/架构时优先读它，不要只看本工作区。
6. **git 状态**（CONFIRMED）：backend ✓、admin ✓、app ✓。
