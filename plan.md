# 项目规划

## 项目概述
仿抖音竖屏滑动浏览播放视频 App，支持 Android 和 Windows 平台。

## 短期规划 (0.1.x)

### 0.1.0 (MINOR) - 首个版本：基础视频浏览
- [ ] 项目基础框架搭建
- [ ] 日志系统
- [ ] 视频数据模型
- [ ] 竖屏滑动浏览 (PageView)
- [ ] 视频播放器 (video_player)
- [ ] 交互按钮 (点赞、评论、分享)
- [ ] 明暗主题支持
- [ ] Android 平台适配
- [ ] Windows 平台适配
- [ ] CI/CD 流水线

### 0.1.1 (PATCH) - 修复 Android 构建
- [x] 升级 Gradle 版本到 9.4.1 修复 Android 构建失败
- [x] 修复 CI metadata job 缺少 checkout 步骤

### 0.1.2 (PATCH) - 重构优化
- [x] 移除 VideoProvider 未使用的 nextVideo/previousVideo 方法
- [x] 移除 HomePage 冗余的 _activeIndex 状态
- [x] 简化 StorageService 单例模式
- [x] 移除 VideoPlayerWidget 冗余的 _lastUrl
- [x] 移除 VideoModel.fromMap，统一使用 fromJson

### 0.1.3 (PATCH) - 重构优化 (预留)
- [ ] 代码重构与优化

## 中期规划 (0.2.x)

### 0.2.0 (MINOR) - 视频源管理
- [x] 本地视频导入
- [x] 视频列表管理
- [x] 视频预加载

### 0.2.1 (PATCH) - 重构优化
- [x] 修复 _VideoListSheet 布局冲突
- [x] 修复已保存视频点赞状态未恢复

### 0.2.2 (PATCH) - 重构优化 (预留)
- [ ] 代码重构与优化

### 0.3.0 (MINOR) - 用户交互增强
- [x] 评论功能
- [x] 收藏功能
- [x] 历史记录

### 0.3.1 (PATCH) - 重构优化
- [x] 修复本地视频无法播放 Bug
- [x] 修复 toggleLike 空安全 + 点赞/评论计数更新
- [x] 添加历史记录查看 UI
- [x] 移除死代码 (darkMode, 未使用的 LogService 方法)
- [x] 统一单例模式 + 减少文件路径重复
- [x] VideoPlayerWidget 添加错误状态展示
- [x] 完善测试用例

## 中期规划 (0.4.x)

### 0.4.0 (MINOR) - 搜索与个人主页
- [x] 视频搜索功能 (按标题/作者搜索)
- [x] 个人主页 (收藏列表、历史记录、使用统计)
- [x] 底部导航栏 (首页/搜索/个人)

### 0.4.1 (PATCH) - 重构优化
- [x] 修复 _showCommentSheet 直接修改 model 字段，改为通过 VideoProvider.incrementComments
- [x] 提取重复的 ID-到-视频解析逻辑为 VideoProvider.getVideosByIds
- [x] 修复 search_page requestFocus 时序问题
- [x] 代码审查与清理
- [x] 更新测试用例

## 中期规划 (0.5.x)

### 0.5.0 (MINOR) - 播放体验增强
- [x] 双击点赞 (心形动画)
- [x] 视频进度条 (可拖拽 seek)
- [x] 静音/取消静音切换
- [x] 视频预加载 (相邻视频预加载)
- [x] 视频循环播放

### 0.5.1 (PATCH) - 修复 CI 编译错误
- [x] 修复 heart 变量声明前引用问题
- [x] 修复 seek 方法名应为 seekTo

### 0.5.2 (PATCH) - 修复 Windows 视频播放
- [x] 替换 video_player 为 media_kit 修复 Windows 平台视频播放
- [x] 更新 VideoPlayerWidget 适配 media_kit API
- [x] 更新 VideoPreloadService 适配 media_kit API
- [x] 更新 pubspec.yaml 依赖
- [x] 更新 CI 构建流程适配 media_kit

### 0.5.3 (PATCH) - 修复 Android 构建 JVM 兼容性
- [x] 统一所有子项目 Kotlin JVM 目标为 21，修复 volume_controller 等插件编译失败

### 0.5.4 (PATCH) - 重构优化
- [x] 修复 toggleLike/incrementComments 中文数字解析 Bug（"1.2万" 解析失败导致数据丢失）
- [x] 修复 VideoPlayerWidget 重复添加监听器导致内存泄漏
- [x] 拆分 home_page.dart 提取独立组件（_TopToolbar、_VideoListSheet、_VideoPage）
- [x] 优化 getVideosByIds 查找效率（O(n) → O(1)）
- [x] 修复 LogService 同步文件写入为异步
- [x] 移除 _CircleAvatar 未使用的 video 参数
- [x] 搜索页添加防抖
- [x] InteractionService 添加防抖持久化
- [x] 完善测试用例
- [x] 代码审查与清理

## 中期规划 (0.6.x)

### 0.6.0 (MINOR) - 播放增强与设置
- [x] 播放速度控制 (0.5x ~ 2.0x)
- [x] 设置页面 (播放设置、清除缓存、关于)
- [x] 视频时长格式化优化
- [x] 下拉刷新视频

### 0.6.1 (PATCH) - 移除预置网络视频
- [x] 移除预置网络视频，启动时提醒加载本地视频 (fix #2)
- [x] 移除 VideoProvider.resetToSampleVideos 方法
- [x] 移除 VideoListSheet 恢复默认按钮
- [x] 优化空状态 UI 引导用户导入本地视频
- [x] 更新测试用例

### 0.6.2 (PATCH) - 修复视频比例与 Android 构建
- [x] 修复视频保持原比例填充容器 (fix #3)
- [x] 修复 Android 构建 compileSdk 兼容性问题

### 0.6.3 (PATCH) - 重构优化
- [x] 提取 _formatDuration 为共享工具函数
- [x] 提取 _showSpeedSheet 为独立组件 SpeedSheet
- [x] 修复 _heartId 在视频切换时不重置的 Bug
- [x] 提取 _showCommentSheet 为独立组件 CommentSheet
- [x] 提取 _showHistorySheet 为独立组件 HistorySheet
- [x] 提取 profile_page 中 _showListSheet 为共享组件 VideoListSheet
- [x] 代码审查与清理
- [x] 更新测试用例

## 中期规划 (0.7.x)

### 0.7.0 (MINOR) - 视频管理增强
- [x] 视频缩略图生成与展示
- [x] 视频列表排序 (按名称/时长/导入时间)
- [x] 视频详情信息 (分辨率、时长、文件大小)
- [x] 视频列表搜索过滤

### 0.7.1 (PATCH) - 修复 issue #4 反馈问题
- [x] 修复播放器原生控制界面显示，禁用原生控件
- [x] 修复 Android 滑动切换视频被播放器阻碍
- [x] 修复播放暂停按钮无法控制视频
- [x] 修复搜索界面输入文字垂直居中
- [x] 修复搜索框外点击键盘不收起
- [x] 添加深浅模式切换功能
- [x] 修复"我的"界面查看全部改为全屏页面
- [x] 实现横屏全屏播放及界面适配

## 短期规划 (0.8.x)

### 0.8.0 (MINOR) - 视频分类与批量管理
- [x] 视频分类管理 (创建/编辑/删除分类，视频归类)
- [x] 视频信息编辑 (重命名标题、编辑描述)
- [x] 批量操作 (批量删除、批量归类)
- [x] 分享功能 (调用系统分享)
- [x] 自动连播开关

### 0.8.1 (PATCH) - 重构优化
- [x] 修复 CI 测试 batchDelete 竞态条件失败
- [x] 修复收藏按钮点击后 UI 不更新 (fix #8)
- [x] 修复心形动画 onDone 回调缺少 mounted 检查
- [x] 优化进度条合并 ValueListenableBuilder 减少重建
- [x] InteractionService 添加 changeNotifier 通知 UI 刷新

## 短期规划 (0.9.x)

### 0.9.0 (MINOR) - 播放增强与体验优化
- [x] 播放列表功能 (创建/编辑/删除播放列表，添加/移除视频)
- [x] 定时关闭播放 (15/30/60分钟/自定义)
- [x] 播放统计 (播放次数、观看时长、最后播放时间)
- [x] 视频列表缩略图优化

### 0.9.1 (PATCH) - 修复 CI 编译错误
- [x] 修复 home_page.dart showModalBottomSheet 缺少闭合括号导致语法错误
- [x] 修复 home_page.dart 未使用的 import (category_service.dart)
- [x] 修复 home_page.dart const 构造函数建议
- [x] 修复 settings_page.dart deprecated activeColor → activeTrackColor
- [x] 修复 sleep_timer_service.dart unnecessary_brace_in_string_interps
- [x] 修复 video_actions.dart unnecessary_underscores
- [x] 修复 test/playback_stats_test.dart const 建议

### 0.9.2 (PATCH) - 修复 issue #9 多视频同时发声
- [x] 修复 VideoPreloadService 预加载时视频自动播放并发声 (fix #9)
- [x] 修复 VideoPlayerWidget 创建时短暂自动播放导致相邻视频同时发声
- [x] 预加载 Player 强制静音并禁用 autoplay
- [x] 添加预加载/播放器静音相关测试用例

### 0.9.3 (PATCH) - 修复 CI 测试失败
- [x] 修复 PlaybackStatsService 单例在测试间状态污染导致 totalPlayCount/totalWatchTime 测试失败
- [x] PlaybackStatsService 添加 clear() 方法用于测试隔离
- [x] playback_stats_test 添加 setUp 隔离单例状态

### 0.9.4 (PATCH) - 重构优化
- [x] 移除 VideoPreloadService 冗余的 reset() 方法（与 clear() 等价）
- [x] 测试用例迁移至 clear()
- [x] README.md 更新最新 5 个版本介绍，旧版本压缩

## 长期规划 (1.0.x)

### 1.0.0 (MAJOR) - 完整功能
- [ ] 用户系统
- [ ] 云端同步
- [ ] 社交分享

## 短期规划 (0.7.x)

### 0.7.2 (PATCH) - 修复 issue #5 反馈问题
- [x] 去掉倍速、声音、全屏控制按钮和相关功能
- [x] 手机横屏后视频自动进入全屏播放模式
- [x] 滑动切换到新视频时上一个视频暂停播放
- [x] 评论界面半屏显示
- [x] 搜索界面搜索内容垂直居中
- [x] 浅色模式切换后整个 app 界面变成白底浅色
- [x] 修复状态栏经常自动消失的问题

### 0.7.3 (PATCH) - 重构优化
- [x] 提取 _buildSubtitle 为共享工具函数（4处重复）
- [x] 提取 _HeartAnimation 为独立组件
- [x] 提取 _FullScreenVideoList 为独立组件
- [x] 修复静默异常吞噬，添加日志记录
- [x] 修复 video_source_service.dart 潜在资源泄漏
- [x] 修复 video_preload_service.dart 不一致导入
- [x] 优化 home_page.dart _onPageChanged URL 列表创建
- [x] 优化 video_player_widget.dart setState 频率
- [x] 添加测试 tearDown 隔离单例服务
- [x] 代码审查与清理
- [x] 更新测试用例

### 0.7.4 (PATCH) - 修复 issue #6
- [x] 修复滑动切换视频时上一个视频仍在后台播放，未释放播放资源
