# Musha Refactor Todo

1. [x] 宠物/随从系统：统一 Yamche、Arong、Dall 的跟随/休息状态切换入口，减少多实体状态不一致。
2. [x] 技能系统：已完成闪电命中档位、女武神闪电启动、魔力恢复、护盾、睡眠、主要技能魔力消耗表驱动化。
3. [x] 资源/动画系统：已新增 `scripts/musha_animutils.lua`，集中核心角色 `SetBuild`、`AddOverrideBuild`、`OverrideSymbol` 入口，并在 `docs/02_资源声明.md` 记录资源声明与运行时动画职责边界。
4. [x] 周期任务和事件监听：已新增 `scripts/musha_taskutils.lua`，集中 Musha 主体常驻任务、客户端资源同步监听、幽灵/人类状态监听和主要战斗事件监听的注册与清理。
5. [x] 配置系统：已增强 `tools/build_modinfo.ps1`，生成和检查都会验证 `modinfo_src` 源文件、全部配置分组和生成后的 `modinfo.lua` 可被 `luac -p` 解析。

## modmain.lua 拆分计划

1. [x] 第一阶段（低风险）：已拆出 `scripts/musha/config/config.lua`、`scripts/musha/config/postinit.lua`、`scripts/musha/equipment/postinit.lua`、`scripts/musha/world/postinit.lua`、`scripts/musha/world/difficulty_postinit.lua`，让 `modmain.lua` 只保留模块加载索引和仍未迁移的技能/RPC/伴侣逻辑。
2. [x] 第二阶段（中风险）：已拆出 `scripts/musha/companions/commands.lua`，集中 Yamche、Arong、Dall 的命令 RPC 和状态切换逻辑，并复用 `scripts/musha/companions/states.lua` 处理查找、跟随、休息和跨世界迁移。
3. [x] 第三阶段（高风险）：逐步拆出技能/RPC 逻辑，减少 `modmain.lua` 里的主动技能、资源消耗、失败反馈和服务端校验代码。
   - [x] 主动护盾：已拆到 `scripts/musha_skill_shield.lua`，负责主动护盾 RPC、魔力消耗、冷却、范围伤害和失败校验。
   - [x] 闪电技能：已拆到 `scripts/musha_skill_lightning.lua`，迁移 `Lightning_a`、主动闪电命中回调、档位伤害、魔力消耗、失败反馈、幽灵复仇闪电和 R 键入口关联的武器电击状态。
   - [x] 女武神/狂暴技能：`buff` RPC 已由 `scripts/musha_skill_music.lua` 承接；女武神/狂暴主体状态仍保留在 `scripts/prefabs/musha.lua`，不再属于 `modmain.lua` 拆分范围。
   - [x] 睡眠技能：已拆到 `scripts/musha_skill_sleep.lua`，迁移 `sleeping` RPC、深度睡眠/浅睡眠/唤醒、睡眠前战斗状态清理和输入状态保护逻辑。
   - [x] 暗影技能：已拆到 `scripts/musha_skill_shadow.lua`，迁移 `shadows`/`HideIn` 相关入口、隐身状态、目标筛选、潜行攻击、被发现清理和失败反馈。
   - [x] 音乐技能：已拆到 `scripts/musha_skill_music.lua`，迁移音乐/嗅探/宝藏生成/召唤类技能入口，恢复 `buff` RPC 注册，并保留幽灵犬、暗影分身、冰触手召唤关系。
   - [x] 外观切换 RPC：已拆到 `scripts/musha_visual_commands.lua`，迁移 `visual_cos`、`visual_human`、`visual_hold` 注册和外观循环逻辑，保留旧外观状态字段。
   - [x] RPC 索引收敛：已整理 `modmain.lua` 中剩余 RPC 注册位置，并同步更新 `docs/01_配置与入口.md` 索引。
4. [x] 收尾阶段（低风险）：拆出 `modmain.lua` 中剩余的非入口职责，让它只保留配置读取、模块加载、注册顺序和角色注册。
   - [x] 信息显示 RPC：已拆到 `scripts/musha_info_commands.lua`，迁移 `INFO`、`INFO2`、Yamche/Critter 信息标记逻辑，保留原 RPC 名称和按键行为。
   - [x] 伴侣血量悬浮信息：已拆到 `scripts/musha/companions/hoverinfo.lua`，迁移 Yamche/Arong 的 `health_replica`、`hoverer`、`healthinfo_copy` 注入逻辑。
   - [x] 过期待办复核：已确认 `buff` 入口由 `scripts/musha_skill_music.lua` 承接；剩余女武神/狂暴主体状态在 `scripts/prefabs/musha.lua`，不作为 `modmain.lua` 拆分项。
   - [x] RPC/文档索引收敛：已整理 `modmain.lua`、技能模块和伴侣模块中的 RPC 注册位置，并同步更新 `docs/01_配置与入口.md`。

## 文件系统整理计划

> 原则：优先整理普通 `require`/`modimport` 逻辑模块；`scripts/prefabs/`、`scripts/brains/`、`scripts/stategraphs/`、`scripts/components/`、`scripts/widgets/` 属于 DST 约定目录，先不整体移动。Prefab 文件保留原路径，后续只把内部大段逻辑抽到业务目录。

1. [x] 第一阶段（低风险）：整理纯逻辑模块到业务目录。
   - [x] 技能模块：已将 `musha_skill_lightning.lua`、`musha_skill_shield.lua`、`musha_skill_sleep.lua`、`musha_skill_shadow.lua`、`musha_skill_music.lua`、`musha_skilldefs.lua` 收敛到 `scripts/musha/skills/`。
   - [x] 配置模块：已将 `musha_config.lua`、`musha_config_postinit.lua` 收敛到 `scripts/musha/config/`。
   - [x] 工具模块：已将 `musha_animutils.lua`、`musha_taskutils.lua`、`musha_name_fallbacks.lua` 收敛到 `scripts/musha/utils/`。
   - [x] 保留旧路径兼容壳，避免仍引用旧 `require("musha_*")` 的代码立即失效。
   - [x] 清理第一阶段兼容壳：已在实机启动、选人、技能/配置/工具相关回归通过后，确认无旧路径引用，并删除 `musha_skill*.lua`、`musha_config*.lua`、`musha_animutils.lua`、`musha_taskutils.lua`、`musha_name_fallbacks.lua` 等旧入口壳。
2. [x] 第二阶段（中风险）：整理伴侣与装备相关 PostInit/命令模块。
   - [x] 伴侣模块：已将 `musha_companioncommands.lua`、`musha_companionstates.lua`、`musha_companion_hoverinfo.lua` 收敛到 `scripts/musha/companions/`。
   - [x] 装备模块：已将 `musha_equipment_postinit.lua`、`musha_equiputils.lua`、`musha_inventory_overflow.lua` 收敛到 `scripts/musha/equipment/`。
   - [x] 世界/难度模块：已将 `musha_world_postinit.lua`、`musha_difficulty_postinit.lua` 收敛到 `scripts/musha/world/`。
   - [x] 重点回归 Arong、Dall、Yamche、冰霜护甲、海盗箱子和额外装备栏兼容。
   - [x] 清理第二阶段兼容壳：已在伴侣、装备、世界/难度模块回归后，确认无旧路径引用，并删除本阶段新增的旧入口壳。
3. [x] 第三阶段（高风险）：拆分超大 prefab 内部逻辑，但不移动 prefab 入口文件。
   - [x] `scripts/prefabs/musha.lua`：逐步抽出等级、形态、技能状态、保存读取和常驻任务逻辑。
     - [x] 第一轮：保存/预加载字段逻辑已抽到 `scripts/musha/prefabs/musha_save.lua`，保留旧保存字段名。
     - [x] 第二轮：死亡等级惩罚表已抽到 `scripts/musha/prefabs/musha_death.lua`。
     - [x] 收尾：形态切换、技能状态和常驻任务当前已由 `scripts/musha/skills/`、`scripts/musha/utils/task.lua` 等模块承接，入口 prefab 暂保留编排逻辑。
   - [x] `scripts/prefabs/musha_small.lua`：逐步抽出成长阶段、形态替换和伴侣行为配置。
     - [x] 第一轮：成长时间入口已抽到 `scripts/musha/prefabs/musha_small_growth.lua`。
     - [x] 收尾：成长阶段和形态替换仍由 prefab 入口编排，后续仅在具体玩法调整时继续拆分。
   - [x] `scripts/prefabs/arong*.lua`：抽出 Arong 忠诚、骑乘、成长和跨世界跟随辅助逻辑。
     - [x] 第一轮：Arong 永久忠诚、玩家攻击不反击和目标清理辅助已抽到 `scripts/musha/prefabs/arong_loyalty.lua`。
     - [x] 第二轮：骑乘倾向、睡眠继承和 Buck 延迟计算已抽到 `scripts/musha/prefabs/arong_riding.lua`。
   - [x] `scripts/prefabs/moontree_musha.lua` / `greenworm.lua`：抽出 Dall 植物生成、kkobong 转换、忠诚和跨世界迁移逻辑。
     - [x] 第一轮：Dall 植物标记/上限、kkobong 标记/还原、跨世界迁移计数已抽到 `scripts/musha/prefabs/dall_lifecycle.lua`。
     - [x] 第二轮：Dall 周期召唤任务注册已收敛到 `dall_lifecycle.lua`；`greenworm.lua` 寻家/受击共享目标已抽到 `scripts/musha/prefabs/greenworm_behavior.lua`。
   - [x] `scripts/prefabs/broken_frosthammer.lua`：抽出冰霜护甲防御、容器和冰箱逻辑。
     - [x] 第一轮：容器打开/关闭、常开入口和格挡音效辅助已抽到 `scripts/musha/prefabs/frost_armor.lua`。
     - [x] 第二轮：右键防御开启/关闭、理智消耗和护盾燃料消耗已收敛到 `frost_armor.lua`；冰冻反击和等级成长由 prefab 入口继续编排。
   - [x] 清理第三阶段兼容壳：第三阶段没有创建旧路径兼容壳，无需清理。

## 代码审查待办

1. [x] 修补明显的 `nil` 风险点，优先检查 `scripts/musha_adds_actions.lua` 中的 follower / machine / container 直接解引用。
2. [x] 收敛冰霜护甲与额外背包的联动逻辑，减少 `containers.widgetsetup` 多层重写带来的兼容风险。
3. [x] 复查冰霜护甲右键防御、开关容器、理智消耗的状态切换，避免事件重复触发或互相打架。
4. [x] 复查 `scripts/musha/prefabs/musha_save.lua` 的保存/读取逻辑，清掉旧分支和可疑死代码。
5. [x] 复查 `scripts/musha/world/postinit.lua` 的 hit symbol 覆盖顺序，确认没有被后写逻辑意外覆盖。
6. [x] 复查 Dall / Arong / Yamche 的命令链路，尽量减少重复 `FindEntities` 扫描和状态残留。
7. [x] 统一装备、人物状态、召唤物和贴图同步的入口，避免以后再出现“补丁叠补丁”的写法。
