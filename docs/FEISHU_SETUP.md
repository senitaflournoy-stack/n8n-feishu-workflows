# 飞书配置指南

## 1. 飞书群机器人

在用于接收通知的飞书群中添加“自定义机器人”，复制机器人 Webhook，并将其作为 `FEISHU_BOT_WEBHOOK` 提供给 n8n。

Webhook 本身相当于密钥，不要写入公开仓库。建议在机器人安全设置中启用关键词、IP 白名单或签名校验。当前模板直接支持 Webhook；如果启用签名校验，需要在发送节点前增加签名计算步骤。

## 2. 飞书自建应用

在飞书开放平台创建企业自建应用，获取 App ID 和 App Secret。为应用申请多维表格相关权限，至少包括目标场景需要的记录读取或记录写入权限。

应用取得权限后，还需要把应用添加为目标多维表格的协作者，否则 API 仍可能返回无权限。

## 3. 找到 App Token 和 Table ID

打开目标多维表格，从页面地址或飞书开放平台调试工具中取得：

- App Token：通常是 `bascn...` 或相似格式
- Table ID：通常是 `tbl...`

将它们配置为 `FEISHU_BITABLE_APP_TOKEN` 和 `FEISHU_BITABLE_TABLE_ID`。

## 4. n8n Cloud 变量

当前工作流使用 `$vars.变量名`。在 n8n Cloud 中打开对应项目，进入 `Variables`，逐项创建：

- `LLM_API_URL`
- `LLM_API_KEY`
- `LLM_MODEL`
- `FEISHU_BOT_WEBHOOK`
- `FEISHU_APP_ID`
- `FEISHU_APP_SECRET`
- `FEISHU_BITABLE_APP_TOKEN`
- `FEISHU_BITABLE_TABLE_ID`
- 03 工作流使用 DeepSeek 视觉 OCR，无需单独填写 OCR 服务变量；`file_url` 必须是 DeepSeek 可访问的图片地址

推荐默认值：`LLM_API_URL=https://api.deepseek.com/chat/completions`、`LLM_MODEL=deepseek-flash`。03 工作流直接通过 DeepSeek 视觉能力识别图片，PDF 需先转换为图片。Webhook、App Secret 和 API Key 都属于敏感信息，不要发送到聊天或提交到 GitHub。

### 自托管 n8n

自托管 Docker Compose 示例：

```yaml
services:
  n8n:
    environment:
      - LLM_API_URL=https://api.deepseek.com/chat/completions
      - LLM_API_KEY=${LLM_API_KEY}
      - LLM_MODEL=deepseek-flash
      - FEISHU_BOT_WEBHOOK=${FEISHU_BOT_WEBHOOK}
      - FEISHU_APP_ID=${FEISHU_APP_ID}
      - FEISHU_APP_SECRET=${FEISHU_APP_SECRET}
      - FEISHU_BITABLE_APP_TOKEN=${FEISHU_BITABLE_APP_TOKEN}
      - FEISHU_BITABLE_TABLE_ID=${FEISHU_BITABLE_TABLE_ID}
```

自托管环境若只设置了进程环境变量，需要将模板中的 `$vars.` 改成 `$env.`；也可以在 n8n 中创建同名 Variables。若管理员禁止工作流读取环境变量，请将 HTTP Request 节点改为使用 n8n Credentials，或将取飞书 Token 的步骤封装到仅管理员可编辑的私有子工作流。

## 5. Webhook 地址

导入并保存工作流后，n8n 会生成测试地址和生产地址：

- 测试时点击 `Listen for test event` 后调用 Test URL。
- 激活工作流后调用 Production URL。

不要把测试 URL 当成长期生产入口。生产 Webhook 建议开启反向代理、HTTPS、访问控制和请求频率限制。

## 6. 社区节点（可选）

如果希望在界面中直接使用飞书节点，可评估：

https://github.com/imsnae/n8n-nodes-feishu

社区节点会在 n8n 进程中运行第三方代码。安装前请检查源码、版本维护情况和权限范围。当前项目默认使用内置 HTTP Request 节点，因此不要求安装社区节点。
