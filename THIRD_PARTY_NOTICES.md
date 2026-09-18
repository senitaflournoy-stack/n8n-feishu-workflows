# 第三方来源与修改说明

本项目参考了以下公开模板集合中的工作流思路：

- 项目：Awesome n8n Templates
- 上游仓库：https://github.com/enescingoz/awesome-n8n-templates
- 上游作者：Enes Cingoz 及模板原始贡献者
- 上游许可：Creative Commons Attribution 4.0 International（CC BY 4.0）
- 许可证：https://github.com/enescingoz/awesome-n8n-templates/blob/main/LICENSE

重点参考的模板：

1. `InboxZero Lite - AI Email Classifier.json`
   - https://github.com/enescingoz/awesome-n8n-templates/blob/main/Gmail_and_Email_Automation/InboxZero%20Lite%20-%20AI%20Email%20Classifier.json
2. `Chat with a Google Sheet using AI.json`
   - https://github.com/enescingoz/awesome-n8n-templates/blob/main/Google_Drive_and_Google_Sheets/Chat%20with%20a%20Google%20Sheet%20using%20AI.json
3. `Extract text from PDF and image using Vertex AI (Gemini) into CSV.json`
   - https://github.com/enescingoz/awesome-n8n-templates/blob/main/PDF_and_Document_Processing/Extract%20text%20from%20PDF%20and%20image%20using%20Vertex%20AI%20(Gemini)%20into%20CSV.json

## 主要修改

- 重新编排工作流结构，并统一使用中文节点名称和提示词。
- 将 Gmail/Google Drive/Google Sheets/Slack 替换为 IMAP、飞书机器人和飞书多维表格 API。
- 将固定 OpenAI/Gemini 节点替换为可配置的 OpenAI 兼容 HTTP 接口。
- 删除上游实例 ID、凭证 ID、账号名、硬编码目录和第三方品牌注释。
- 增加邮件脱敏、结构化输出容错、错误提示和中文使用文档。
- 文档处理工作流改为直接调用 DeepSeek 视觉能力进行图片文字识别；保留 OpenAI 兼容接口形式，便于替换为其他国内模型服务。

上游集合说明指出，部分模板可能还有原作者条款。这里提供的三个 JSON 是针对上述思路重新设计的飞书版本，并保留本文件作为合理署名和修改记录。
