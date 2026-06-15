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

## 长期规划 (1.0.x)

### 1.0.0 (MAJOR) - 完整功能
- [ ] 用户系统
- [ ] 云端同步
- [ ] 社交分享
