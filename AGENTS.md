# AGENTS.md

你是在维护一个《Don't Starve Together》角色 Mod：`[DST]Musha`。  
你的目标不是把它改造成普通软件项目，而是在尊重 DST Mod 运行环境、玩家体验、存档兼容和多人联机同步的前提下，理解、修复、优化并扩展这个游戏内容项目。

## 项目定位

- Mod 名称：`[DST]Musha`
- 版本：`T 14.2.4`
- 类型：DST 服务端角色 Mod，`server_only_mod = true`，`all_clients_require_mod = true`
- 核心玩法：RPG 等级成长、四态角色形态、主动技能、法力/疲劳/耐力资源、专属装备成长、伴侣/召唤物、独立 UI、怪物难度强化、多语言文本。
- 当前目录已使用 Git 管理。改动前后应查看 `git status`，但不要回滚用户未要求回滚的改动。

## 文档优先入口

本项目已经在 `docs/` 下整理了较完整的功能说明和代码索引。处理任何需求时，优先把 `docs/` 当作入口和导航，不要直接从几千行 Lua 文件盲找。

推荐阅读顺序：

1. `docs/00_架构总览.md`：项目全局结构、模块依赖、核心风险。
2. `docs/01_配置与入口.md`：`modinfo.lua` 配置项、`modmain.lua` 加载顺序、RPC、PostInit 索引。
3. 根据任务类型阅读对应专题文档。
4. 根据文档里的文件/函数索引进入代码定位。
5. 如果代码行为和文档不一致，以代码为准，并在完成改动后同步修正文档。

## docs/ 功能索引

- `docs/00_架构总览.md`：整体架构、模块地图、主要技术债和高风险区域。
- `docs/01_配置与入口.md`：Mod 配置、快捷键、难度配置、入口加载顺序、RPC 注册、原版 prefab 修改。
- `docs/02_资源声明.md`：`PrefabFiles`、动画、贴图、音效等资源声明。
- `docs/03_角色属性与状态.md`：Musha 基础属性、四态切换、组件、NetVar、核心状态标记。
- `docs/04_等级与经验系统.md`：角色等级、击杀/进食经验、等级里程碑、装备等级、伴侣经验共享。
- `docs/05_技能系统.md`：闪电、冰风暴、强力攻击、暗影、护盾、音乐/嗅探、睡眠、被动技能、施法状态图。
- `docs/06_法力疲劳耐力系统.md`：`spellpower`、`fatigue_sleep`、`stamina_sleep` 三条资源组件与 UI 同步。
- `docs/07_装备系统.md`：武器、护甲、帽子、装备成长、耐久、专属装备限制。
- `docs/08_伴侣与召唤物.md`：Arong、Yamche、Dall、月龙、幽灵犬、暗影分身、保镖、小 Musha。
- `docs/09_物品与材料.md`：材料、食物、特殊物品、掉落和使用方式。
- `docs/10_UI与界面.md`：资源 Badge、HUD 注入、快捷键 UI、原版 UI 覆盖风险。
- `docs/11_配方系统.md`：合成标签、配方材料、难度差异、builder tag。
- `docs/12_行为与状态图.md`：玩家扩展状态、实体 StateGraph、动作状态衔接。
- `docs/13_AI行为树.md`：伴侣和召唤物 Brain 行为逻辑。
- `docs/14_世界物件.md`：建筑、植物、世界实体和生成逻辑。
- `docs/15_难度系统.md`：怪物强化档位、倍率、标签、全服影响。
- `docs/16_本地化.md`：中英韩俄文本、手动语言配置、台词和物品名。

## 代码定位规则

文档用于索引，代码用于最终确认。常见代码入口如下：

- 配置和入口：`docs/01_配置与入口.md` → `modinfo.lua`、`modmain.lua`
- Mod 配置维护：`modinfo_src/` → `tools/build_modinfo.ps1` → `modinfo.lua`
- 资源：`docs/02_资源声明.md` → `scripts/prefabasset.lua`
- 角色主体：`docs/03_角色属性与状态.md` → `scripts/prefabs/musha.lua`
- 等级经验：`docs/04_等级与经验系统.md` → `scripts/prefabs/musha.lua`
- 技能：`docs/05_技能系统.md` → `scripts/musha/skills/`、`scripts/mypower_musha_1.lua`、`scripts/musha_adds_states.lua`
- 三条资源：`docs/06_法力疲劳耐力系统.md` → `scripts/components/`、`scripts/widgets/`
- 装备：`docs/07_装备系统.md` → `scripts/prefabs/mushasword*.lua`、`armor_musha*.lua`、`hat_m*.lua`
- 伴侣/召唤物：`docs/08_伴侣与召唤物.md` → `scripts/prefabs/`、`scripts/brains/`、`scripts/stategraphs/`
- UI：`docs/10_UI与界面.md` → `scripts/widgets/`、`data/screens/`、`data/widgets/controls.lua`
- 配方：`docs/11_配方系统.md` → `scripts/musha_adds_recipe.lua`
- 难度：`docs/15_难度系统.md` → `scripts/difficulty_monster_dst.lua`
- 本地化：`docs/16_本地化.md` → `scripts/strings_musha_*.lua`、`scripts/speech_musha_*.lua`

## 游戏开发优先级

处理任何需求时，按以下顺序权衡：

1. **不破坏存档**：不要随意重命名 prefab、组件字段、保存字段、网络变量或配置项。必须改名时要提供迁移兼容。
2. **多人同步正确**：主动技能、按键、UI、召唤物和状态变化要区分客户端/服务端。服务端权威逻辑放在服务端，客户端只做输入、预测或显示。
3. **玩法平衡可解释**：数值调整要说明影响范围，例如早期、中期、后期、Boss 战、多人服务器、非 Musha 玩家。
4. **兼容 DST API**：优先使用 `AddPrefabPostInit`、`AddClassPostConstruct`、组件和 RPC 等增量 Hook；谨慎覆盖原版文件。
5. **可读性服务于维护**：这个项目历史代码很长，局部清理可以做，但不要借小修复进行大规模重构。
6. **玩家体验优先**：避免卡顿、刷屏、无反馈、误触快捷键、资源条显示错误、召唤物失控、无限刷物或强制影响全服玩家。

## 编码原则

保留通用工程原则，但要按游戏 Mod 场景落地：

- **KISS**：修复问题时优先做最小、直观、稳定的改动。不要为一个技能或物品引入复杂框架。
- **YAGNI**：只实现当前玩法需求。不要提前设计大型配置系统、抽象层或未使用的兼容逻辑。
- **DRY**：重复数值表、等级区间、prefab 注册可以逐步收敛，但必须保证行为不变。
- **SRP**：新代码尽量按“配置读取、数值计算、状态变更、特效表现、保存读取”拆清职责。
- **数据驱动优先**：等级阈值、伤害倍率、配方、难度倍率适合表驱动，避免复制几十段几乎相同的 `if`。

## DST/Lua 约束

- 使用 Lua 写法时遵循项目现有风格，避免引入外部依赖。
- 每次修改 `.lua` 文件后，必须执行 Lua 语法检查。优先使用 `luac -p <file>` 检查本次改动过的 Lua 文件；涉及生成文件时先生成再检查，例如修改 `modinfo_src/` 后先运行 `tools/build_modinfo.ps1`，再检查生成的 `modinfo.lua`。
- `.lua` 文件必须保存为 UTF-8 无 BOM。DST 的 Lua 会把 UTF-8 BOM 识别成非法字符，导致 `modmain.lua:1: unexpected symbol near '�'`，并直接禁用整个模组；`luac -p` 不一定能发现这个问题。使用 PowerShell 改写文件时不要用 Windows PowerShell 5 的 `Set-Content -Encoding utf8` 直接写 Lua 文件，必要时使用 `[System.Text.UTF8Encoding]::new($false)` 写入无 BOM 文件。
- 新函数默认使用 `local`，避免污染全局环境。
- 使用 `GLOBAL`、`TUNING`、`STRINGS`、`ACTIONS` 时确认 DST Mod 沙盒环境可访问。
- 通过 `require("xxx")` 加载的 `scripts/*.lua` 模块不等同于 `modmain.lua` 环境，DST strict 模式下直接访问未声明的 `GLOBAL` 会在实机启动时报 `variable 'GLOBAL' is not declared`，而 `luac -p` 检查不出来。拆模块时优先由 `modmain.lua` 显式传入需要的 `STRINGS`、`TUNING`、`TheSim`、`SpawnPrefab`、`ProfileStatsSet` 等依赖，模块内部通过 `env.xxx` 使用；不要在 require 模块里隐式读取 `GLOBAL`。
- 服务端逻辑要检查 `TheWorld.ismastersim` 或现有项目里的 `IsServer` 模式。
- RPC 命名空间当前主要为 `musha`。新增 RPC 要明确输入来源、服务端校验和失败条件。
- 保存字段要保持向后兼容。`OnSave`/`OnLoad` 中新增字段应能处理旧存档缺失值。
- 对周期任务、范围搜索、生成实体等逻辑要特别关注性能，避免每帧大范围扫描。

## 宠物/召唤物开发规范

本项目的 Yamche、Dall、Arong 已经暴露过多次历史问题：命令状态和自然状态混用、跨地上/洞穴后 leader/follower 残留、召唤物反复变形、死亡路径空组件崩溃、重复添加组件刷日志。后续处理宠物、坐骑、随从、临时召唤物时，按以下规则优先检查。

### 命令状态与自然状态分离

- 不要让一个字段同时表达多种含义。例如 `sleep_on` 不应同时表示“玩家命令休息”“夜晚自然睡眠”“主人睡觉同步”“无主人待机”。
- 对复杂宠物使用明确字段拆分：`command_follow`、`command_sleep`、`force_sleep`、`idle_sleep`、`is_summoned`、`owner_userid` 等，再由一个刷新函数计算最终表现状态。
- 玩家命令只能由快捷键/RPC 或明确交互修改；昼夜、饥饿、主人睡觉、AI 行为只能修改自然状态字段，不能反向覆盖玩家命令。
- 切换跟随/休息时要同步清理互斥字段。例如进入跟随应清掉休息命令、临时睡眠和待机睡眠；进入休息应清掉跟随、攻击、采集、召唤等活动状态。

### Leader/Follower 所有权

- 跟随关系必须同时考虑 `components.follower.leader` 和玩家 `components.leader:IsFollower()`/`CountFollowers()`，不要只改其中一边。
- 同类宠物只能跟随一个时，命令逻辑应优先查找“已拥有的 follower”，再查找“可命令的无主实体”，避免多宠物状态错位。
- 推荐复用 `scripts/musha/companions/states.lua` 里的查找、跟随、休息封装；不要在 `modmain.lua` 中重复写大段 `FindEntities` 和 leader/follower 操作。
- 多人场景下只允许当前主人影响宠物状态。不要用“附近任意 Musha”决定睡眠、召回、休息、攻击或传送。

### 地上/洞穴与跨世界

- 宠物需要跟随玩家穿越地上/洞穴时，必须检查传送后 leader/follower 是否仍一致，命令键是否还能正确在“呼唤”和“休息”之间切换。
- 跨世界后不要只依赖旧的本地字段判断是否正在跟随，应以服务端真实 follower 关系为准重新恢复命令态。
- 对需要跟随换层的宠物，测试必须覆盖：地上呼唤进洞、洞穴休息回地上、戴在头上/容器内/休息状态换层、主人死亡或变鬼换层。

### 召唤物生命周期

- 召唤物和可还原实体要有明确来源标记，例如 `dall_owner`、`dall_plant`、`dall_drake`，避免影响世界自然生成物。
- “植物变召唤物”“召唤物变植物”“装备脱下变宠物”等流程必须是单向且条件清晰，不能让周期任务在跟随状态下再次把召唤物还原。
- 休息命令应立即处理召唤物回收或还原，不要只等待下一次周期扫描。
- 生成上限要基于仍然有效的实体动态统计；玩家采集、死亡、移除后应释放名额，避免永久卡上限。

### AI、StateGraph 与周期任务

- Brain 决定“想做什么”，StateGraph 决定“动作怎么播放”，prefab 周期任务只做少量状态维护；不要把战斗、睡眠、生成、跟随、台词、特效全部塞进一个周期函数。
- 周期扫描要限制频率、半径、标签和目标数量。能用 leader、保存的实体引用或事件回调时，不要每秒全范围搜索。
- StateGraph 中访问组件前要判断组件是否存在，尤其是 `lootdropper`、`combat`、`follower`、`sleeper`、`container`。
- 死亡、移除、睡眠、变形、进入容器、装备/卸下等状态转换要清理任务、目标、leader/follower 和临时标记。

### 保存、加载与兼容

- 不随意改 prefab 名、保存字段、组件名、网络变量。必须改时提供旧字段兼容读取。
- 新增状态字段要允许旧存档缺失，读取时给默认值；不要假设 `data.xxx.yyy` 一定存在。
- 保存命令态时要区分“玩家长期意图”和“临时运行状态”。例如可以保存休息/跟随意图，但不应保存一次性的攻击目标或短期特效状态。
- 组件只能添加一次。对历史 prefab 可用 helper 包装 `AddComponent`，先判断 `inst.components.xxx == nil` 再添加，避免日志 warning 或组件覆盖。

### 验证清单

- 快捷键/RPC：能呼唤、休息、再次呼唤；附近没有宠物时有正确失败反馈。
- 多宠物：一个跟随、一个休息、装备/卸下、召唤/回收时状态不串。
- 跨世界：地上/洞穴双向切换后命令状态和实体状态一致。
- 保存读取：保存退出重进后，跟随、休息、等级、装备、召唤物上限不异常。
- 死亡与移除：宠物死亡、主人死亡、召唤物死亡、实体被采集或移除都不报错、不残留 follower。
- 兼容性：与 Insight、Quick Work 等常见 Mod 同开时，不刷重复组件 warning，不劫持其他 Mod 的实体或 UI。

## 修改高风险区域

这些区域改动前必须先定位调用链，改动后必须重点验证：

- `modmain.lua`：入口加载顺序、模块注册、语言加载和角色注册集中在此；调整时必须确认 require/modimport 顺序。
- `modinfo.lua`：DST 运行时读取的生成文件。不要手改配置项，改 `modinfo_src/` 后运行 `tools/build_modinfo.ps1`。
- `scripts/prefabs/musha.lua`：角色核心文件，影响等级、形态、技能、保存、按键。
- `data/screens/` 与 `data/widgets/controls.lua`：同名 UI Hook，容易与游戏更新或其他 Mod 冲突。
- `scripts/difficulty_monster_dst.lua`：影响全服怪物，不仅影响 Musha。
- `scripts/musha_adds_container.lua`：容器布局定义；冰霜护甲与额外背包显示互斥逻辑在 `scripts/musha/equipment/inventory_overflow.lua`。
- 装备成长 prefab：改动伤害、耐久、保存字段会影响已有装备。

## 工作流程

1. **先读上下文**
   - 先读 `docs/00_架构总览.md` 和 `docs/01_配置与入口.md`，建立全局入口和加载顺序。
   - 再按任务类型阅读对应专题文档，例如技能读 `docs/05_技能系统.md`，装备读 `docs/07_装备系统.md`，UI 读 `docs/10_UI与界面.md`。
   - 从专题文档给出的文件、函数、prefab、组件、RPC、配置项进入代码。
   - 确认行为是在客户端、服务端，还是两边都有。
   - 发现文档与代码不一致时，以代码为准，并记录需要同步更新的文档点。

2. **限定改动范围**
   - 明确本次是修 Bug、调数值、加玩法、改 UI、做兼容，还是整理文档。
   - 不顺手改无关旧代码。
   - 遇到历史问题可以记录，但不要扩大本次变更。

3. **实现时考虑游戏行为**
   - 技能：检查消耗、冷却、目标筛选、特效、失败反馈、RPC 同步。
   - 装备：检查装备/卸下、耐久、燃料、伤害、防御、保存读取。
   - 伴侣：检查 leader/follower、AI、死亡、掉落、保存、传送、攻击目标。
   - UI：检查不同分辨率、洞穴/地上、客户端刷新、资源变化事件。
   - 配方：检查科技等级、builder tag、材料合理性、语言文本。
   - 难度：检查是否影响非 Musha 玩家和服务器整体体验。

4. **验证**
   - 至少做静态检查：括号、`local`、未定义变量、文件路径、require/modimport 路径。
   - 只要本次改动包含 `.lua` 文件，就必须运行 `luac -p` 做语法检查，并在汇报中写明检查过的文件或批量检查命令。
   - 新增或拆分 `require("scripts_xxx")` 模块后，要额外检查模块内是否直接引用了 `GLOBAL` 或依赖 `modmain.lua` 局部变量；这类问题通常只能从 DST `server_log.txt` 的 `scripts/strict.lua` 报错中发现。
   - 涉及 `modmain.lua`、`modinfo.lua` 或脚本批量改写时，额外检查 Lua 文件头是否存在 UTF-8 BOM；如果选人页 Musha 消失且日志显示 `unexpected symbol near '�'`，优先排查入口文件 BOM。
   - 能运行游戏时，优先在测试世界验证：
     - 创建 Musha。
     - 使用相关快捷键/RPC。
     - 保存并重进。
     - 地上与洞穴分别检查。
     - 多人场景下确认客户端 UI 和服务端状态一致。
   - 无法运行 DST 时，要明确说明未做实机验证。

5. **汇报**
   - 说明改了哪些文件。
   - 如果更新了代码索引或功能说明，说明同步改了哪些 `docs/` 文档。
   - 说明玩家可感知变化。
   - 说明验证情况和剩余风险。
   - 如果改动影响平衡，给出数值依据。

## 输出风格

- 用中文回复，除非用户明确要求其他语言。
- 直接说明结论和具体改动，不写泛泛的软件工程套话。
- 遇到风险要明确指出，尤其是存档、联机同步、全服怪物、原版 UI 覆盖。
- 如果只做文档或分析，不要假装已经实机验证。
