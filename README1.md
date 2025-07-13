# CloudFront Distribution with WAF IP Whitelist Protection

这个项目提供了一个完整的 CloudFront Distribution 解决方案，包含 WAF IP 白名单保护和 Lambda@Edge 404 重定向功能。

## 🏗️ 架构概述

```
Internet → WAF (IP Whitelist) → CloudFront → Lambda@Edge → S3 Bucket
```

### 核心组件

1. **CloudFront Distribution**: 内容分发网络
2. **WAF Web ACL**: IP 白名单保护，支持 IPv4 和 IPv6
3. **Lambda@Edge**: 404 重定向和路径处理
4. **S3 Origin**: 静态内容存储

## 📁 文件结构

```
├── cloudfront-waf-template.yaml    # CloudFormation 模板
├── parameters.json                 # 参数配置文件
├── deploy.sh                      # 自动部署脚本
├── README.md                      # 本文档
└── manual-deployment-guide.md     # 手动部署指南
```

## 🚀 快速部署 (CloudFormation)

### 前置要求

1. AWS CLI 已安装并配置
2. 具有以下权限的 AWS 账户：
   - CloudFormation 完整权限
   - CloudFront 完整权限
   - WAF v2 完整权限
   - Lambda 完整权限
   - IAM 角色创建权限

### 步骤 1: 准备参数

编辑 `parameters.json` 文件，配置您的参数：

```json
[
  {
    "ParameterKey": "S3BucketDomainName",
    "ParameterValue": "your-bucket-name.s3.your-region.amazonaws.com"
  },
  {
    "ParameterKey": "OriginAccessIdentityId", 
    "ParameterValue": "YOUR_OAI_ID"
  },
  {
    "ParameterKey": "AllowedIPv4Addresses",
    "ParameterValue": "1.2.3.4/32,5.6.7.8/32"
  },
  {
    "ParameterKey": "AllowedIPv6Addresses",
    "ParameterValue": "2001:db8::1/128"
  }
]
```

### 步骤 2: 执行部署

```bash
# 使用默认参数部署
./deploy.sh

# 指定自定义参数
./deploy.sh my-stack-name my-aws-profile us-east-1
```

### 步骤 3: 验证部署

部署完成后，您将看到以下输出：

```
📊 Stack Outputs:
|  OutputKey                        |  OutputValue                    |
|  CloudFrontDistributionId         |  E1234567890ABC                |
|  CloudFrontDistributionDomainName |  d1234567890abc.cloudfront.net |
|  WAFWebACLArn                     |  arn:aws:wafv2:...             |
```

## 🔧 参数说明

| 参数名 | 描述 | 示例值 |
|--------|------|--------|
| `S3BucketDomainName` | S3 存储桶域名 | `my-bucket.s3.us-east-1.amazonaws.com` |
| `OriginAccessIdentityId` | CloudFront OAI ID | `E1K3Y1A1IBH4GU` |
| `AllowedIPv4Addresses` | 允许的 IPv4 地址列表 | `1.2.3.4/32,5.6.7.8/32` |
| `AllowedIPv6Addresses` | 允许的 IPv6 地址列表 | `2001:db8::1/128` |
| `DistributionComment` | CloudFront 分发注释 | `My Distribution` |
| `PriceClass` | 价格等级 | `PriceClass_All` |

## 🛡️ WAF 保护功能

### IP 白名单规则

- **IPv4 支持**: 支持多个 IPv4 地址，CIDR 格式
- **IPv6 支持**: 支持多个 IPv6 地址，CIDR 格式  
- **默认动作**: 阻止所有未在白名单中的 IP
- **监控**: 启用 CloudWatch 指标和采样请求

### 安全特性

- 只有白名单中的 IP 可以访问
- 支持动态 IP 更新
- 详细的访问日志和指标
- 自动阻止恶意请求

## 🔄 Lambda@Edge 功能

### 404 重定向规则

Lambda@Edge 函数处理以下重定向：

1. **子目录访问重定向**:
   - `/website1/` → `/website1/index.html`
   - `/website2/` → `/website2/index.html`
   - `/app1/` → `/app1/index.html`

2. **404 错误重定向**:
   - `/website1/any-path` → `/website1/index.html`
   - `/website2/any-path` → `/website2/index.html`
   - `/app1/any-path` → `/app1/index.html`

3. **静态资源保护**:
   - 不重定向 `.html`, `.css`, `.js` 文件

## 📊 监控和日志

### CloudWatch 指标

- **WAF 指标**: 
  - `AllowIPv4WhitelistRule`
  - `AllowIPv6WhitelistRule`
  - `{StackName}-WAF-Metrics`

- **CloudFront 指标**:
  - 请求数量
  - 错误率
  - 缓存命中率

### 日志位置

- **Lambda@Edge 日志**: `/aws/lambda/us-east-1.{FunctionName}`
- **WAF 日志**: 可配置到 S3 或 CloudWatch Logs

## 🔄 更新和维护

### 更新 IP 白名单

1. **通过 CloudFormation**:
   ```bash
   # 更新 parameters.json 中的 IP 地址
   ./deploy.sh your-stack-name
   ```

2. **通过 AWS CLI**:
   ```bash
   aws wafv2 update-ip-set \
     --scope CLOUDFRONT \
     --id YOUR_IP_SET_ID \
     --addresses "1.2.3.4/32,5.6.7.8/32" \
     --lock-token YOUR_LOCK_TOKEN
   ```

### 更新 Lambda@Edge 函数

1. 修改 CloudFormation 模板中的函数代码
2. 重新部署 CloudFormation 栈
3. 等待 CloudFront 分发更新完成

## 🧪 测试验证

### 基本功能测试

```bash
# 测试正常访问（从白名单 IP）
curl -I https://your-distribution.cloudfront.net

# 测试 404 重定向
curl -I https://your-distribution.cloudfront.net/website1/non-existent

# 测试子目录重定向
curl -I https://your-distribution.cloudfront.net/website1/
```

### WAF 测试

```bash
# 从非白名单 IP 测试（应该返回 403）
curl -I https://your-distribution.cloudfront.net
# 预期结果: HTTP/2 403

# 从白名单 IP 测试（应该返回 200）
curl -I https://your-distribution.cloudfront.net  
# 预期结果: HTTP/2 200
```

## 💰 成本估算

### 主要成本组件

1. **CloudFront**: 按数据传输和请求数量计费
2. **WAF**: $1/月 + $0.60/百万请求
3. **Lambda@Edge**: $0.60/百万请求 + 计算时间
4. **CloudWatch**: 日志和指标存储

### 成本优化建议

- 选择合适的 CloudFront 价格等级
- 配置适当的缓存策略
- 监控和优化 Lambda@Edge 执行时间

## 🚨 故障排除

### 常见问题

1. **403 错误**:
   - 检查 IP 是否在白名单中
   - 验证 WAF 规则配置
   - 检查 S3 存储桶策略

2. **Lambda@Edge 错误**:
   - 查看 CloudWatch 日志
   - 验证函数权限
   - 检查函数代码语法

3. **部署失败**:
   - 检查 IAM 权限
   - 验证参数格式
   - 查看 CloudFormation 事件

### 调试命令

```bash
# 查看 CloudFormation 事件
aws cloudformation describe-stack-events --stack-name your-stack-name

# 查看 WAF 采样请求
aws wafv2 get-sampled-requests \
  --web-acl-arn YOUR_WAF_ARN \
  --rule-metric-name YOUR_RULE_METRIC \
  --scope CLOUDFRONT \
  --time-window StartTime=2023-01-01T00:00:00Z,EndTime=2023-01-01T23:59:59Z

# 查看 Lambda@Edge 日志
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/us-east-1"
```

## 🔐 安全最佳实践

1. **定期更新 IP 白名单**
2. **启用 CloudTrail 记录 API 调用**
3. **配置 CloudWatch 告警**
4. **定期审查访问日志**
5. **使用最小权限原则**

## 📚 相关文档

- [AWS CloudFront 文档](https://docs.aws.amazon.com/cloudfront/)
- [AWS WAF 文档](https://docs.aws.amazon.com/waf/)
- [Lambda@Edge 文档](https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html)
- [CloudFormation 文档](https://docs.aws.amazon.com/cloudformation/)

## 🤝 支持和贡献

如有问题或建议，请：

1. 查看故障排除部分
2. 检查 AWS 服务状态
3. 联系技术支持团队

---

**注意**: 部署前请确保您了解相关的 AWS 服务费用，并在测试环境中验证配置。
