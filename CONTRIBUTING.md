# 🤝 贡献指南

感谢您对 CloudFront WAF Deployment 项目的关注！我们欢迎各种形式的贡献。

## 📋 贡献方式

### 🐛 报告 Bug
- 使用 [Bug Report 模板](https://github.com/your-username/cloudfront-waf-deployment/issues/new?template=bug_report.md)
- 提供详细的重现步骤
- 包含错误信息和环境信息

### 💡 功能建议
- 使用 [Feature Request 模板](https://github.com/your-username/cloudfront-waf-deployment/issues/new?template=feature_request.md)
- 描述具体的使用场景
- 说明预期的行为

### 📝 改进文档
- 修复文档中的错误
- 添加更多示例
- 改进说明的清晰度

### 💻 代码贡献
- 修复 Bug
- 添加新功能
- 优化性能
- 改进测试覆盖率

## 🚀 开发流程

### 1. Fork 项目
```bash
# Fork 项目到您的 GitHub 账户
# 然后克隆到本地
git clone https://github.com/your-username/cloudfront-waf-deployment.git
cd cloudfront-waf-deployment
```

### 2. 创建分支
```bash
# 创建功能分支
git checkout -b feature/your-feature-name

# 或者创建修复分支
git checkout -b fix/your-bug-fix
```

### 3. 开发和测试
```bash
# 进行您的更改
# 测试 CloudFormation 模板
aws cloudformation validate-template --template-body file://cloudfront-waf-template.yaml

# 测试部署脚本
./deploy.sh test-stack test-profile us-east-1

# 运行功能测试
./test-deployment.sh your-test-distribution.cloudfront.net
```

### 4. 提交更改
```bash
# 添加更改
git add .

# 提交更改（使用清晰的提交信息）
git commit -m "feat: add support for custom SSL certificates"

# 或者
git commit -m "fix: resolve WAF rule priority conflict"
```

### 5. 推送和创建 PR
```bash
# 推送到您的 fork
git push origin feature/your-feature-name

# 在 GitHub 上创建 Pull Request
```

## 📝 代码规范

### CloudFormation 模板
- 使用清晰的资源命名
- 添加详细的描述和注释
- 遵循 AWS 最佳实践
- 使用参数化配置

### Shell 脚本
- 使用 `set -e` 处理错误
- 添加详细的注释
- 提供清晰的输出信息
- 支持参数验证

### 文档
- 使用清晰的标题结构
- 提供具体的示例
- 包含必要的截图
- 保持内容更新

## 🧪 测试要求

### 必需测试
- CloudFormation 模板验证
- 部署脚本功能测试
- 文档链接检查

### 推荐测试
- 多区域部署测试
- 不同参数组合测试
- 性能基准测试

## 📋 Pull Request 检查清单

在提交 PR 之前，请确保：

- [ ] 代码遵循项目规范
- [ ] 添加了必要的测试
- [ ] 更新了相关文档
- [ ] CloudFormation 模板验证通过
- [ ] 部署脚本测试通过
- [ ] 提交信息清晰明确
- [ ] PR 描述详细说明了更改内容

## 🏷️ 提交信息规范

使用以下前缀：
- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `style:` 代码格式化
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

示例：
```
feat: add support for custom domain names
fix: resolve Lambda@Edge timeout issue
docs: update deployment guide with new examples
```

## 🔍 代码审查

所有 PR 都需要经过代码审查：

### 审查重点
- 功能正确性
- 安全性考虑
- 性能影响
- 文档完整性
- 测试覆盖率

### 审查流程
1. 自动化检查（CI/CD）
2. 维护者审查
3. 社区反馈
4. 最终批准和合并

## 🎯 开发优先级

### 高优先级
- 安全漏洞修复
- 关键 Bug 修复
- 文档错误修正

### 中优先级
- 新功能开发
- 性能优化
- 用户体验改进

### 低优先级
- 代码重构
- 非关键功能
- 实验性功能

## 📞 获取帮助

如果您在贡献过程中遇到问题：

- 📧 发送邮件到 your-email@example.com
- 💬 在 [GitHub Discussions](https://github.com/your-username/cloudfront-waf-deployment/discussions) 中提问
- 🐛 创建 [Issue](https://github.com/your-username/cloudfront-waf-deployment/issues) 寻求帮助

## 🏆 贡献者认可

我们会在以下地方认可贡献者：
- README.md 中的贡献者列表
- 发布说明中的感谢
- 项目网站（如果有）

## 📄 许可证

通过贡献代码，您同意您的贡献将在 MIT 许可证下发布。

---

**感谢您的贡献！** 🎉

每一个贡献都让这个项目变得更好。无论是报告 Bug、建议功能、改进文档还是提交代码，我们都非常感激！
