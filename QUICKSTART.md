# 🚀 快速开始指南

## 5分钟部署 CloudFront + WAF + Lambda@Edge

### 📋 前置要求

- AWS CLI 已安装并配置
- 具有必要权限的 AWS 账户
- 已有 S3 存储桶和 OAI

### 🔧 快速部署

1. **获取您的 IP 地址**:
   ```bash
   curl -s https://ipinfo.io/ip
   ```

2. **编辑参数文件**:
   ```bash
   # 编辑 parameters.json
   {
     "S3BucketDomainName": "your-bucket.s3.region.amazonaws.com",
     "OriginAccessIdentityId": "YOUR_OAI_ID",
     "AllowedIPv4Addresses": "YOUR_IP/32",
     "AllowedIPv6Addresses": "::1/128"
   }
   ```

3. **一键部署**:
   ```bash
   ./deploy.sh my-stack-name my-profile us-east-1
   ```

4. **等待完成** (约15-20分钟)

5. **测试访问**:
   ```bash
   curl -I https://YOUR_DISTRIBUTION.cloudfront.net
   ```

### ✅ 验证清单

- [ ] CloudFront 返回 HTTP/2 200
- [ ] 非白名单 IP 返回 403
- [ ] Lambda@Edge 重定向正常工作
- [ ] WAF 指标在 CloudWatch 中可见

### 🔗 有用链接

- [完整文档](README.md)
- [手动部署指南](manual-deployment-guide.md)
- [故障排除](#troubleshooting)

### 🆘 快速故障排除

| 问题 | 解决方案 |
|------|----------|
| 403 错误 | 检查 IP 白名单 |
| 部署失败 | 检查 IAM 权限 |
| Lambda 错误 | 查看 CloudWatch 日志 |

---
**需要帮助？** 查看完整的 [README.md](README.md) 文档。
