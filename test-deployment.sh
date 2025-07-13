#!/bin/bash

# CloudFront with WAF - Deployment Test Script
# Usage: ./test-deployment.sh [distribution-domain]

set -e

DISTRIBUTION_DOMAIN=${1:-""}

if [ -z "$DISTRIBUTION_DOMAIN" ]; then
    echo "❌ Please provide the CloudFront distribution domain name"
    echo "Usage: ./test-deployment.sh d1234567890abc.cloudfront.net"
    exit 1
fi

echo "🧪 Testing CloudFront Distribution: $DISTRIBUTION_DOMAIN"
echo ""

# Test 1: Basic access
echo "🔍 Test 1: Basic access from current IP"
RESPONSE=$(curl -s -I https://$DISTRIBUTION_DOMAIN)
STATUS=$(echo "$RESPONSE" | head -n1 | cut -d' ' -f2)

if [ "$STATUS" = "200" ]; then
    echo "✅ Basic access: PASSED (HTTP $STATUS)"
else
    echo "❌ Basic access: FAILED (HTTP $STATUS)"
    echo "   This might indicate WAF is blocking your IP"
fi

# Test 2: Lambda@Edge redirect - website1
echo ""
echo "🔍 Test 2: Lambda@Edge redirect for /website1/"
REDIRECT_RESPONSE=$(curl -s -I https://$DISTRIBUTION_DOMAIN/website1/)
REDIRECT_STATUS=$(echo "$REDIRECT_RESPONSE" | head -n1 | cut -d' ' -f2)
LOCATION=$(echo "$REDIRECT_RESPONSE" | grep -i "location:" | cut -d' ' -f2 | tr -d '\r')

if [ "$REDIRECT_STATUS" = "302" ] && [ "$LOCATION" = "/website1/index.html" ]; then
    echo "✅ Lambda@Edge redirect: PASSED (302 → $LOCATION)"
else
    echo "❌ Lambda@Edge redirect: FAILED (Status: $REDIRECT_STATUS, Location: $LOCATION)"
fi

# Test 3: Lambda@Edge redirect - website2
echo ""
echo "🔍 Test 3: Lambda@Edge redirect for /website2/"
REDIRECT_RESPONSE2=$(curl -s -I https://$DISTRIBUTION_DOMAIN/website2/)
REDIRECT_STATUS2=$(echo "$REDIRECT_RESPONSE2" | head -n1 | cut -d' ' -f2)
LOCATION2=$(echo "$REDIRECT_RESPONSE2" | grep -i "location:" | cut -d' ' -f2 | tr -d '\r')

if [ "$REDIRECT_STATUS2" = "302" ] && [ "$LOCATION2" = "/website2/index.html" ]; then
    echo "✅ Lambda@Edge redirect: PASSED (302 → $LOCATION2)"
else
    echo "❌ Lambda@Edge redirect: FAILED (Status: $REDIRECT_STATUS2, Location: $LOCATION2)"
fi

# Test 4: 404 redirect
echo ""
echo "🔍 Test 4: Lambda@Edge 404 redirect for /website1/nonexistent"
REDIRECT_404=$(curl -s -I https://$DISTRIBUTION_DOMAIN/website1/nonexistent)
REDIRECT_404_STATUS=$(echo "$REDIRECT_404" | head -n1 | cut -d' ' -f2)
LOCATION_404=$(echo "$REDIRECT_404" | grep -i "location:" | cut -d' ' -f2 | tr -d '\r')

if [ "$REDIRECT_404_STATUS" = "302" ] && [ "$LOCATION_404" = "/website1/index.html" ]; then
    echo "✅ Lambda@Edge 404 redirect: PASSED (302 → $LOCATION_404)"
else
    echo "❌ Lambda@Edge 404 redirect: FAILED (Status: $REDIRECT_404_STATUS, Location: $LOCATION_404)"
fi

# Test 5: Performance test
echo ""
echo "🔍 Test 5: Performance test"
PERF_START=$(date +%s%N)
curl -s -o /dev/null https://$DISTRIBUTION_DOMAIN
PERF_END=$(date +%s%N)
PERF_TIME=$(( (PERF_END - PERF_START) / 1000000 ))

echo "✅ Response time: ${PERF_TIME}ms"

# Summary
echo ""
echo "📊 Test Summary for $DISTRIBUTION_DOMAIN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$STATUS" = "200" ]; then
    echo "✅ Basic Access: WORKING"
else
    echo "❌ Basic Access: FAILED - Check WAF IP whitelist"
fi

if [ "$REDIRECT_STATUS" = "302" ]; then
    echo "✅ Lambda@Edge Redirects: WORKING"
else
    echo "❌ Lambda@Edge Redirects: FAILED - Check function deployment"
fi

if [ "$PERF_TIME" -lt 1000 ]; then
    echo "✅ Performance: GOOD (${PERF_TIME}ms)"
elif [ "$PERF_TIME" -lt 3000 ]; then
    echo "⚠️  Performance: ACCEPTABLE (${PERF_TIME}ms)"
else
    echo "❌ Performance: SLOW (${PERF_TIME}ms)"
fi

echo ""
echo "🔗 Useful Commands:"
echo "   View WAF logs: aws wafv2 get-sampled-requests --web-acl-arn YOUR_WAF_ARN --scope CLOUDFRONT"
echo "   View Lambda logs: aws logs describe-log-groups --log-group-name-prefix '/aws/lambda/us-east-1'"
echo "   CloudFront invalidation: aws cloudfront create-invalidation --distribution-id YOUR_DIST_ID --paths '/*'"
echo ""
