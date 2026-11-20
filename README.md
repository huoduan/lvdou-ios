# 绿豆影视 iOS（iPhone 版）

SwiftUI + AVPlayer，iOS 15+，界面按「深色 + 毛玻璃 + 悬浮 Dock」效果图实现。
后台完全复用现有 `tt.lvdoui.net` 接口，**不改后台**。

## 目录

```
LvdouTV/
├── project.yml                 # XcodeGen 工程描述
├── Sources/
│   ├── App/                    # 入口 + 根视图（Dock 三 Tab）
│   ├── Core/                   # 主题、模型、网络（含 AES 解密）、全局状态
│   ├── Components/             # LOGO 槽位、Dock、海报卡、区块标题
│   └── Features/               # 首页/详情/播放/我的/搜索/历史/直播
├── Resources/Info.plist
└── .github/workflows/build.yml # macOS runner 出未签名 IPA
```

## 编译

本机（Mac）：

```bash
brew install xcodegen
xcodegen generate
open LvdouTV.xcodeproj
```

命令行：

```bash
xcodebuild -project LvdouTV.xcodeproj -scheme LvdouTV \
  -sdk iphoneos -configuration Release archive
```

没有 Mac：推 GitHub，Actions 里跑 `build-ipa`，产物是**未签名** `LvdouTV-unsigned.ipa`，
用 Sideloadly / AltStore / TrollStore 自签安装。

## 已实现

- 顶部：LOGO 固定 80×28 槽位（`scaledToFit` 等比完整显示，未配置留空）+ 搜索胶囊 + 历史按钮，同一排位置固定
- 首页：轮播 Banner、分类 chips、海报网格（3 列）、底部悬浮 Dock
- 详情：头图、播放/收藏、简介、线路切换、选集网格、相关推荐
- 播放：AVPlayer + 自绘玻璃控制条（进度/播放暂停/时间/全屏占位）
- 我的：用户卡、会员卡、八宫格、设置项
- 搜索 / 历史 / 直播：可直接用的基础页面
- 网络：`api/main/init` 拉取 `app_config`（logo/splash/backdrop/player/service），
  自动识别后台的加密响应（16 位 key + AES-128-CBC）与明文 JSON

## 待接

- 后台 `homeConfig` 实际结构解析（现在是宽松字段匹配 + 示例数据兜底）
- 登录/注册/卡密/收藏/签到等用户接口（Token 已留 `TokenStore`）
- js 源（JavaScriptCore）与 py 源（内嵌 CPython，后续接）

## 后台对接配置

所有对接参数集中在 `Sources/Core/AppEnv.swift`，改域名 / 换应用只改这一处（按字段名改）：

| 字段 | 含义 | 当前值（与安卓一致） |
|---|---|---|
| `baseURL` | 后台域名 | http://tt.lvdoui.net |
| `appId` | 应用 ID（app_id 去 demo） | 10000 |
| `appMark` | 应用标识（app_mark） | lvdou-box-ui-6 |
| `appKey` | 应用密钥（app_key） | 7E3EFC…280C5 |

这三个与安卓端 `App.java getAppInfo()` 完全对应，你搭好后台换域名时，
改 `AppEnv.baseURL` 一个字段即可。

## LOGO 规则

- 后台「应用管理 → logoimage」上传，支持任意尺寸
- 客户端固定槽位 80×28pt，等比缩放到槽位内，不拉伸、不裁切
- 未配置：槽位留空，不显示文字或占位图
