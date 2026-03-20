# Week 2 开发切片

目标：在 Week 1 搭建的基础上完善各个核心机制，包括战斗深度、物品系统、回响系统等，为后续内容扩展打下坚实基础。

## 范围

### 地图

- 沿用 Week 1 的 8 个场景（V01-S01），不做新地图
- 在现有场景中添加更多交互点和可拾取物品
- 优化场景切换流畅度

### 已确认设定

- **战斗**：添加更多敌人类型，完善 AI 行为树，增加战斗节奏变化
- **物品**：实现物品拾取、使用、装备切换的基础框架
- **回响**：山海回响的首次正式互动机制（不仅是指引，还包括能力赋予）
- **存档**：雨眠时记录更多状态（已击败敌人、已触发事件等）
- **事件系统**：从硬编码改为配置驱动，提升可维护性
- **代码结构**：提取 RoomBase 基类，消除房间脚本的重复代码

## 功能待办

### 事件系统重构
- [x] 重构 event.csv 格式（添加 trigger_condition, event_type, content 字段）
- [x] 创建 RoomBase 基类统一处理玩家创建、信号连接、复活逻辑
- [x] 创建 EventManager 全局管理事件触发和执行
- [x] 创建事件执行器（dialogue, cg, spawn_enemy, tutorial, message, ambience）
- [x] 将 8 个房间脚本迁移到 RoomBase，删除约 400 行冗余代码
- [x] 房间配置迁移到 room.csv（status_text, default_spawn）

### 战斗系统深化
- [ ] 实现敌人巡逻和警戒范围可视化
- [ ] 添加敌人受击硬直动画
- [ ] 优化弹反窗口和反馈效果
- [ ] 实现连击计数和连击奖励

### 物品系统框架
- [ ] 实现物品拾取交互
- [ ] 创建物品栏 UI（最小实现）
- [ ] 实现消耗品使用（如简易治疗道具）
- [ ] 装备切换的基础逻辑

### 回响系统原型
- [ ] 实现山海回响的首次"低语"互动
- [ ] 添加回响给予的基础能力（如感知附近敌人）
- [ ] 回响出现的视觉特效优化

### 存档系统增强
- [ ] 雨眠时记录已触发事件
- [ ] 雨眠时记录已击败的敌人
- [ ] 实现区域状态持久化（如 G03 影隐事件只触发一次）

## 测试待办

- [ ] 事件系统：所有 Week 1 的事件能正常触发
- [ ] 事件系统：新的事件类型（spawn_enemy）能正常工作
- [ ] 事件系统：事件链（EV_V001 -> EV_V002）能正确执行
- [ ] 房间系统：8 个房间都能正常初始化和传送
- [ ] 房间系统：死亡复活逻辑正常
- [ ] 房间系统：room.csv 配置正确加载

## 本周记录

### Wave 1 已完成

**时间：** 2025-03-20

**完成内容：**

1. **事件系统重构（配置驱动）**：
   - 重构 `data/event.csv` 格式，从描述性文档改为机器可解析的配置
   - 新增字段：`trigger_condition`（触发条件）、`event_type`（事件类型）、`content`（JSON配置内容）
   - 支持的事件类型：dialogue, cg, spawn_enemy, tutorial, message, ambience
   - 支持的触发条件：first_enter, event_complete, interact_object, enemy_cleared, proximity_npc

2. **RoomBase 基类创建**：
   - 提取所有房间的公共逻辑：玩家创建/销毁、信号连接、复活逻辑
   - 提供事件回调接口：`play_cg_event()`, `spawn_enemies()`, `show_dialogue()`, `show_tutorial()`
   - 子类只需覆盖特定方法即可自定义行为
   - 每个房间脚本从 70-120 行减少到 20-40 行

3. **EventManager 实现**：
   - 全局 autoload，负责事件加载、触发条件检查、执行器调度
   - 管理事件完成状态，支持事件链（一个事件完成后自动触发下一个）
   - 提供房间注册接口，自动处理 first_enter 事件

4. **事件执行器系统**：
   - `dialogue_executor.gd` - 显示对话（HUD 状态栏）
   - `cg_executor.gd` - 播放过场动画（调用房间的 play_cg_event）
   - `spawn_enemy_executor.gd` - 动态生成敌人
   - `tutorial_executor.gd` - 显示教程提示
   - `message_executor.gd` - 显示一次性消息
   - `ambience_executor.gd` - 环境效果（区域名显示等）

5. **房间脚本迁移**：
   - V01-V04, G01-G03, S01 全部改为继承 RoomBase
   - V01 保留开场 CG 的特殊逻辑（覆盖 `play_cg_event`）
   - V03 保留山海回响演出（覆盖 `play_cg_event`）
   - G03 保留影隐现身演出（覆盖 `play_cg_event`）
   - 删除约 400 行重复代码

6. **房间配置外置**：
   - `data/room.csv` 新增 `status_text` 和 `default_spawn` 字段
   - RoomBase 自动从 CSV 加载配置
   - 房间脚本只需设置 `room_id`，其他配置自动加载

**遗留问题（Wave 2-4 处理）：**
- [ ] 事件系统的 "proximity_npc" 和 "proximity_enemy" 触发条件待实现
- [ ] 事件执行器的 await 机制需要测试（特别是链式事件）
- [ ] 存档系统尚未记录事件完成状态
- [ ] 敌人 AI 巡逻和警戒范围未实现
- [ ] 物品系统框架未开始
- [ ] 回响系统原型未开始

---

## 本周总结



## 本周不做

- 新地图场景（仍使用 V01-S01）
- 新敌人类型（仍使用 Week 1 的三种敌人）
- Boss 战
- 长兵/法术系统
- 复杂对话分支
- 商店和交易系统
- 正式美术资源
