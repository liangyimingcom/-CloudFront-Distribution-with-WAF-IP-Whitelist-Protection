# 手动部署指南 - CloudFront with WAF IP Whitelist

本指南提供通过 AWS 控制台手动创建 CloudFront Distribution 和 WAF 保护的详细步骤。

## 📋 部署概览

手动部署需要按以下顺序创建资源：

1. **Lambda@Edge 函数** (IAM 角色 + Lambda 函数)
2. **WAF 资源** (IP 集合 + Web ACL)
3. **CloudFront Distribution** (关联 WAF 和 Lambda@Edge)

## 🔧 步骤 1: 创建 Lambda@Edge 函数

### 1.1 创建 IAM 角色

1. 打开 **IAM 控制台** → **角色** → **创建角色**
2. 选择 **AWS 服务** → **Lambda**
3. 添加权限策略：
   - `AWSLambdaBasicExecutionRole`
4. 角色名称：`cloudfront-lambda-edge-role`
5. 创建角色后，编辑**信任关系**，添加：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### 1.2 创建 Lambda 函数

1. 打开 **Lambda 控制台** (必须在 **us-east-1** 区域)
2. **创建函数** → **从头开始创建**
3. 配置：
   - **函数名称**: `cloudfront-404-redirect`
   - **运行时**: `Node.js 18.x`
   - **执行角色**: 使用现有角色 → `cloudfront-lambda-edge-role`

4. 替换函数代码：

```javascript
'use strict';

exports.handler = (event, context, callback) => {
    console.log('Lambda@Edge Origin Request function started');
    console.log('Event:', JSON.stringify(event, null, 2));
    
    try {
        const request = event.Records[0].cf.request;
        
        console.log('Processing request:', {
            uri: request.uri,
            method: request.method
        });
        
        // 处理子目录访问 - 直接重定向，不需要等待S3响应
        if (request.uri === '/website1/' || request.uri === '/website1') {
            console.log('Redirecting /website1/ to /website1/index.html');
            const redirectResponse = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    location: [{
                        key: 'Location',
                        value: '/website1/index.html'
                    }],
                    'cache-control': [{
                        key: 'Cache-Control',
                        value: 'no-cache'
                    }]
                }
            };
            callback(null, redirectResponse);
            return;
        }
        
        if (request.uri === '/website2/' || request.uri === '/website2') {
            console.log('Redirecting /website2/ to /website2/index.html');
            const redirectResponse = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    location: [{
                        key: 'Location',
                        value: '/website2/index.html'
                    }],
                    'cache-control': [{
                        key: 'Cache-Control',
                        value: 'no-cache'
                    }]
                }
            };
            callback(null, redirectResponse);
            return;
        }
        
        if (request.uri === '/app1/' || request.uri === '/app1') {
            console.log('Redirecting /app1/ to /app1/index.html');
            const redirectResponse = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    location: [{
                        key: 'Location',
                        value: '/app1/index.html'
                    }],
                    'cache-control': [{
                        key: 'Cache-Control',
                        value: 'no-cache'
                    }]
                }
            };
            callback(null, redirectResponse);
            return;
        }
        
        // 处理404重定向 - 检查路径模式
        if (request.uri.startsWith('/website1/') && !request.uri.endsWith('.html') && !request.uri.endsWith('.css') && !request.uri.endsWith('.js')) {
            console.log('Redirecting website1 404 to /website1/index.html');
            const redirectResponse = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    location: [{
                        key: 'Location',
                        value: '/website1/index.html'
                    }],
                    'cache-control': [{
                        key: 'Cache-Control',
                        value: 'no-cache'
                    }]
                }
            };
            callback(null, redirectResponse);
            return;
        }
        
        if (request.uri.startsWith('/website2/') && !request.uri.endsWith('.html') && !request.uri.endsWith('.css') && !request.uri.endsWith('.js')) {
            console.log('Redirecting website2 404 to /website2/index.html');
            const redirectResponse = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    location: [{
                        key: 'Location',
                        value: '/website2/index.html'
                    }],
                    'cache-control': [{
                        key: 'Cache-Control',
                        value: 'no-cache'
                    }]
                }
            };
            callback(null, redirectResponse);
            return;
        }
        
        if (request.uri.startsWith('/app1/') && !request.uri.endsWith('.html') && !request.uri.endsWith('.css') && !request.uri.endsWith('.js')) {
            console.log('Redirecting app1 404 to /app1/index.html');
            const redirectResponse = {
                status: '302',
                statusDescription: 'Found',
                headers: {
                    location: [{
                        key: 'Location',
                        value: '/app1/index.html'
                    }],
                    'cache-control': [{
                        key: 'Cache-Control',
                        value: 'no-cache'
                    }]
                }
            };
            callback(null, redirectResponse);
            return;
        }
        
        // 继续正常请求
        console.log('No redirect needed, continuing with original request');
        callback(null, request);
        
    } catch (error) {
        console.error('Error in Lambda@Edge function:', error);
        // 继续原始请求而不是返回错误
        callback(null, event.Records[0].cf.request);
    }
};
```

5. **部署** → **发布新版本**
6. 记录版本 ARN（格式：`arn:aws:lambda:us-east-1:ACCOUNT:function:FUNCTION_NAME:VERSION`）

## 🛡️ 步骤 2: 创建 WAF 资源

### 2.1 创建 IP 集合

1. 打开 **WAF & Shield 控制台** → **IP sets**
2. **Create IP set**

**IPv4 IP 集合**:
- **IP set name**: `ipv4-whitelist`
- **Region**: `CloudFront (Global)`
- **IP version**: `IPv4`
- **IP addresses**: 输入您的 IPv4 地址（如 `1.2.3.4/32`）

**IPv6 IP 集合**:
- **IP set name**: `ipv6-whitelist`
- **Region**: `CloudFront (Global)`
- **IP version**: `IPv6`
- **IP addresses**: 输入您的 IPv6 地址（如 `2001:db8::1/128`）

### 2.2 创建 Web ACL

1. **WAF & Shield 控制台** → **Web ACLs** → **Create web ACL**
2. **基本信息**:
   - **Name**: `cloudfront-ip-whitelist-acl`
   - **Resource type**: `CloudFront distributions`
   - **Region**: `Global (CloudFront)`

3. **添加规则**:

**规则 1 - IPv4 白名单**:
- **Rule type**: `IP set`
- **Name**: `allow-ipv4-whitelist`
- **IP set**: 选择创建的 IPv4 IP 集合
- **Action**: `Allow`
- **Priority**: `1`

**规则 2 - IPv6 白名单**:
- **Rule type**: `IP set`
- **Name**: `allow-ipv6-whitelist`
- **IP set**: 选择创建的 IPv6 IP 集合
- **Action**: `Allow`
- **Priority**: `2`

4. **默认动作**: `Block`
5. **CloudWatch metrics**: 启用
6. **创建 Web ACL**

## 🌐 步骤 3: 创建 CloudFront Distribution

### 3.1 基本配置

1. 打开 **CloudFront 控制台** → **Create distribution**
2. **Origin**:
   - **Origin domain**: 您的 S3 存储桶域名
   - **Origin access**: `Origin access control settings (recommended)`
   - 或使用 **Legacy access identities** 如果您已有 OAI

### 3.2 默认缓存行为

1. **Viewer protocol policy**: `Redirect HTTP to HTTPS`
2. **Allowed HTTP methods**: `GET, HEAD`
3. **Cache policy**: `CachingOptimized`

### 3.3 Lambda@Edge 关联

1. 在 **Function associations** 部分：
   - **Event type**: `Origin request`
   - **Function ARN**: 输入步骤 1.2 中记录的 Lambda 版本 ARN
   - **Include body**: `No`

### 3.4 WAF 关联

1. **Settings** 部分：
   - **AWS WAF web ACL**: 选择步骤 2.2 创建的 Web ACL

### 3.5 其他设置

1. **Price class**: 根据需要选择
2. **Default root object**: `index.html`
3. **Description**: 添加描述
4. **Create distribution**

## ✅ 步骤 4: 验证部署

### 4.1 等待部署完成

- CloudFront 分发状态变为 **Deployed**（通常需要 15-20 分钟）

### 4.2 测试访问

```bash
# 测试正常访问（从白名单 IP）
curl -I https://YOUR_DISTRIBUTION_DOMAIN.cloudfront.net

# 测试 WAF 阻止（从非白名单 IP 或使用代理）
curl -I https://YOUR_DISTRIBUTION_DOMAIN.cloudfront.net
# 应该返回 403 Forbidden

# 测试 Lambda@Edge 重定向
curl -I https://YOUR_DISTRIBUTION_DOMAIN.cloudfront.net/website1/
# 应该重定向到 /website1/index.html
```

## 🔧 配置 S3 存储桶策略

如果使用 Origin Access Identity (OAI)，需要更新 S3 存储桶策略：

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity YOUR_OAI_ID"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    }
  ]
}
```

## 📊 监控和日志

### CloudWatch 指标

1. **WAF 指标**: 在 CloudWatch 中查看 WAF 相关指标
2. **CloudFront 指标**: 监控请求数量、错误率等
3. **Lambda@Edge 日志**: 在各个边缘位置的 CloudWatch 日志组中

### WAF 采样请求

1. **WAF 控制台** → **Web ACLs** → 选择您的 ACL
2. **Sampled requests** 标签页查看被阻止的请求

## 🔄 更新和维护

### 更新 IP 白名单

1. **WAF 控制台** → **IP sets**
2. 选择要更新的 IP 集合
3. **Edit** → 添加或删除 IP 地址
4. **Save changes**

### 更新 Lambda@Edge 函数

1. 修改 Lambda 函数代码
2. **Deploy** → **Publish new version**
3. 更新 CloudFront 分发中的 Lambda 关联
4. 等待 CloudFront 更新完成

## 🚨 故障排除

### 常见问题

1. **Lambda@Edge 部署失败**:
   - 确保函数在 us-east-1 区域
   - 检查 IAM 角色信任关系
   - 验证函数代码语法

2. **WAF 不生效**:
   - 确认 Web ACL 已关联到 CloudFront
   - 检查 IP 地址格式（CIDR）
   - 验证规则优先级和动作

3. **403 错误**:
   - 检查 S3 存储桶策略
   - 验证 Origin Access Identity 配置
   - 确认 IP 在白名单中

### 调试步骤

1. **查看 CloudFront 错误**:
   - 检查 CloudFront 分发状态
   - 查看错误页面配置

2. **检查 WAF 日志**:
   - 启用 WAF 日志记录
   - 查看采样请求

3. **Lambda@Edge 调试**:
   - 查看各区域的 CloudWatch 日志
   - 添加更多日志输出

## 📝 清理资源

删除顺序（避免依赖错误）：

1. **CloudFront Distribution** → Disable → Delete
2. **WAF Web ACL** → Disassociate → Delete
3. **WAF IP Sets** → Delete
4. **Lambda Function** → Delete
5. **IAM Role** → Delete

---

**注意**: 手动部署比 CloudFormation 更容易出错，建议在生产环境中使用 CloudFormation 模板进行部署。
