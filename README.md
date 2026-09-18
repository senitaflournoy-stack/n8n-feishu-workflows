# n8n + 飞书办公自动化工作流

一组面向国内办公场景的 n8n 工作流模板：用飞书机器人负责通知，用飞书多维表格保存结构化数据，用 OpenAI 兼容接口接入 DeepSeek 等模型。

项目不包含任何真实 API Key、飞书 App Secret、机器人 Webhook、邮箱密码或业务数据，可以直接作为公开 GitHub 项目发布。

## 已验证能力

`03-document-extraction-to-bitable.json` 已在 n8n Cloud 中完成端到端测试：图片地址 → DeepSeek 视觉识别 → 字段结构化 → 飞书多维表格写入 → 飞书机器人通知。

## 工作流清单

| 文件 | 用途 | 触发方式 | 适合场景 |
| --- | --- | --- | --- |
| `workflows/01-email-triage-to-feishu.json` | IMAP 邮件脱敏、分类、摘要并推送飞书 | 企业邮箱新邮件 | 邮件提醒、日报摘要 |
| `workflows/02-bitable-ai-analysis.json` | 读取飞书多维表格并按问题生成分析报告 | Webhook | 数据问答、异常总结 |
| `workflows/03-document-extraction-to-bitable.json` | 图片 OCR、字段提取、写入飞书多维表格并通知 | Webhook | 发票、单据、合同截图 |

## 工作流结构

### 01 邮箱 → AI → 飞书

IMAP 新邮件 → 脱敏 → DeepSeek 分类与摘要 → 飞书机器人通知。

工作流只发送摘要，不会自动回复、删除或移动邮件。首次使用建议连接测试邮箱。

### 02 飞书多维表格 → AI 分析 → 飞书

Webhook 接收自然语言问题 → 获取飞书租户 Token → 读取多维表格 → DeepSeek 生成分析 → 飞书机器人通知 → 返回结果。

默认最多读取 500 条记录，当前版本不自动翻页。

### 03 图片 → DeepSeek 视觉 OCR → 飞书多维表格

Webhook 接收 `file_url` → DeepSeek 视觉识别 → 结构化提取 → 写入飞书多维表格 → 飞书机器人通知 → 返回结果。

`file_url` 必须是 DeepSeek 服务可以访问的 JPEG、PNG、GIF 或 WebP 图片地址。PDF 需要先转换为图片；当前模板不直接解析 PDF 文件本体。

## 快速开始

1. 在 n8n 中进入 `Workflows` → `Import from File`。
2. 导入 `workflows` 目录中的 JSON 文件。
3. 在 n8n 项目 `Variables` 页面配置下表变量。
4. 按 [`docs/FEISHU_SETUP.md`](docs/FEISHU_SETUP.md) 完成飞书应用、机器人和多维表格权限配置。
5. 用测试图片或测试邮箱手动运行，确认无误后再发布并激活工作流。

## n8n 变量

工作流使用 n8n 表达式 `$vars.变量名`，适合 n8n Cloud 项目变量。变量值只填写在 n8n 中，不要写入工作流 JSON 或 GitHub。

| 变量 | 用途 | 是否必需 |
| --- | --- | --- |
| `LLM_API_URL` | OpenAI 兼容聊天补全地址，默认 `https://api.deepseek.com/chat/completions` | 是 |
| `LLM_API_KEY` | 模型 API Key | 是 |
| `LLM_MODEL` | 模型名称；图片 OCR 示例使用 `deepseek-flash` | 是 |
| `FEISHU_BOT_WEBHOOK` | 飞书群自定义机器人 Webhook | 01/02/03 需要 |
| `FEISHU_APP_ID` | 飞书自建应用 App ID | 02/03 需要 |
| `FEISHU_APP_SECRET` | 飞书自建应用 App Secret | 02/03 需要 |
| `FEISHU_BITABLE_APP_TOKEN` | 飞书多维表格 App Token | 02/03 需要 |
| `FEISHU_BITABLE_TABLE_ID` | 飞书数据表 ID | 02/03 需要 |

03 工作流现在直接使用 DeepSeek 视觉能力，不需要单独配置 `OCR_API_URL` 和 `OCR_API_KEY`。`.env.example` 中保留的 OCR 变量仅用于兼容旧版或自定义扩展。

自托管 n8n 可以参考 `.env.example`，但需要将工作流表达式中的 `$vars.` 改为 `$env.`，或在 n8n 中创建同名项目变量。

## 飞书多维表格字段

03 工作流默认写入以下中文字段，字段名必须一致：

`文件名`、`文件链接`、`文档类型`、`标题`、`单据编号`、`对方单位`、`金额`、`日期`、`摘要`、`风险提示`、`处理时间`。

## Webhook 请求示例

### 文档提取

```json
{
  "file_url": "https://example.com/sample-invoice.png",
  "source_name": "9月供应商发票.png"
}
```

### 多维表格 AI 分析

```json
{
  "query": "请总结本月最需要关注的事项，并列出三个下一步动作",
  "page_size": 100
}
```

测试 URL 只在 n8n 点击 `Listen for test event` 时临时有效；生产环境应使用激活后的 Production URL，并配合 HTTPS、访问控制和限流。

## 本地检查与打包

在项目目录运行：

```powershell
.\scripts\validate.ps1
```

脚本会检查 JSON 格式、节点名称和连接关系。发布前还应确认搜索不到真实的 `sk-`、Webhook、App Secret 或业务数据。

## 安全与合规

- 飞书机器人 Webhook、App Secret 和模型 API Key 都等同于密码，不要提交到 GitHub。
- 只把允许发送给第三方模型的邮件或图片交给 AI 服务；生产环境请先确认数据合规要求。
- 建议为测试使用独立的飞书群、测试多维表格和测试邮箱。
- 如果曾经误把密钥提交到仓库，应立即在对应平台撤销并重新生成。

## 来源与许可

项目参考公开 n8n 模板的工作流思路，并针对飞书、国内办公环境和 OpenAI 兼容模型接口进行了重新编排与改造。来源、上游链接和修改说明见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。

本项目按 CC BY 4.0 发布，使用和再发布时请保留署名及修改说明，详见 [`LICENSE`](LICENSE)。
