根据你描述的情况，`kubectl` 无法连接到集群而 `nc` 能通但 `openssl s_client` 卡住，通常与 **TLS 证书验证失败**有关。以下是逐步排查和解决方案：

---

### 1. **检查 kubeconfig 的 server 地址**
运行以下命令确认 `server` 字段是否指向 `127.0.0.1` 和正确的端口：
```bash
kubectl config view --minify | grep server
```
- **预期输出**：类似 `server: https://127.0.0.1:41637`。
- **问题**：若 server 是容器内部地址（如 `https://kind-control-plane:6443`），需替换为 `127.0.0.1` 和映射的主机端口。

---

### 2. **验证 API 服务器证书的 SAN**
检查证书是否包含 `127.0.0.1` 作为 Subject Alternative Name (SAN)：
```bash
echo | openssl s_client -connect 127.0.0.1:41637 -servername kind-control-plane 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"
```
- **预期输出**：包含 `IP Address:127.0.0.1` 或相关域名。
- **问题**：若未包含，证书验证失败导致 TLS 握手不完整。

---

### 3. **重新创建集群并指定 SAN**
创建 `kind-config.yaml` 文件，强制添加 SAN：
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      certSANs: ["127.0.0.1"]
networking:
  apiServerAddress: "127.0.0.1"
```
然后创建集群：
```bash
kind delete cluster && kind create cluster --config=kind-config.yaml
```

---

### 4. **手动调整 kubeconfig**
获取新集群的 kubeconfig：
```bash
kind get kubeconfig > ~/.kube/config
```
确保 `server` 字段为 `https://127.0.0.1:随机端口`。

---

### 5. **测试连接**
使用 `openssl` 验证 TLS 握手：
```bash
openssl s_client -connect 127.0.0.1:41637 -servername kind-control-plane
```
- **预期结果**：显示完整的证书链和会话信息，而非卡住。

---

### 6. **检查 API 服务器日志**
进入 control-plane 容器查看日志：
```bash
docker logs kind-control-plane
```
关注是否有证书错误或端口冲突。

---

### **根本原因**
- `openssl s_client` 卡住是因为 TLS 握手未完成，通常由于客户端发送了 SNI（Server Name Indication）而服务器证书不匹配。
- Kind 默认生成的证书可能未包含 `127.0.0.1` 作为 SAN，当使用 IP 连接时触发证书验证失败。

---

### **总结**
通过重新创建集群并明确指定 SAN，确保 API 服务器证书包含 `127.0.0.1`，同时调整 kubeconfig 中的 server 地址，即可解决连接问题。
