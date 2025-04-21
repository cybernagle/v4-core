你的问题涉及在 Ubuntu 环境下使用 kind（Kubernetes IN Docker）部署的 Kubernetes 集群，通过 Docker 包装并暴露在端口 34100 上，使用 kubectl 访问 API Server 时遇到 TLS 握手失败的问题。以下从问题背景、可能原因、遗漏检查点、调试步骤以及 mTLS 可能性等方面进行详细分析，并提供清晰的调试建议。
### 问题背景总结
环境：Ubuntu 系统，kind 部署的 Kubernetes 集群，运行在 Docker 容器中，API Server 暴露在端口 34100。
操作：使用 kubectl 访问本地 34100 端口作为 API Server，执行 kubectl get 命令时，报 TLS 握手失败。
已检查：
TCP 连接到 34100 端口成功。
ufw 防火墙已禁用。
TLS 握手在 Client Hello 后被关闭。
使用 nmap 检查 TLS 加密套件（ciphers）失败。
使用 openssl s_client 连接 34100 端口获取证书失败。
### 疑问：
从客户端到服务端，是否遗漏了某些检查点？
### 如何进一步调试？
是否可能是 mTLS（双向 TLS）导致的问题？如果是，如何调试？
可能导致 TLS 握手失败的层次
TLS 握手失败可能涉及客户端（kubectl）、网络层、Docker 容器网络、API Server 配置（kind 提供的 Kubernetes 控制平面）以及证书相关配置。以下是从客户端到服务端的可能问题层次：
客户端（kubectl）配置问题：
kubectl 使用的 kubeconfig 文件中，API Server 的地址、端口或证书配置错误。
kubeconfig 中的 certificate-authority（CA）、client-certificate 或 client-key 配置不正确或缺失。
kubectl 使用的 TLS 版本或加密套件与 API Server 不兼容。
### 网络层问题：
虽然 TCP 连接成功，但 Docker 网络（如 kind 使用的桥接网络）可能导致 TLS 数据包被意外修改或丢弃。
端口映射（Docker 容器到宿主机的 34100 端口）配置可能不正确，导致流量未正确路由到 API Server。
宿主机或容器内的网络策略（如 CNI 插件）可能干扰 TLS 通信。
### Docker 容器问题：
kind 集群的控制平面容器（运行 API Server）未正确配置 TLS 证书。
端口 34100 的映射可能指向错误的容器或服务。
容器内的 API Server 可能未监听 34100 端口，或监听的 IP 不正确（如仅监听 127.0.0.1）。
API Server（服务端）问题：
Kubernetes API Server 的 TLS 配置错误（如证书无效、过期，或未正确配置）。
API Server 未启用支持的 TLS 版本或加密套件，导致客户端无法协商。
如果启用了 mTLS，API Server 要求客户端提供证书，但 kubectl 未提供有效证书。
### 证书问题：
API Server 的服务器证书无效、过期或不受信任。
客户端无法验证服务器证书（CA 证书缺失或不匹配）。
如果是 mTLS，客户端证书未正确配置或未被 API Server 信任。
### 可能遗漏的检查点
根据你的描述，以下是一些可能遗漏的关键检查点：
kubeconfig 文件配置：
检查 ~/.kube/config 或指定的 kubeconfig 文件，确保：
server 字段指向正确的地址（如 https://localhost:34100 或 https://<宿主机IP>:34100）。
certificate-authority 或 certificate-authority-data 是否指向正确的 CA 证书。
如果需要客户端证书，确认 client-certificate 和 client-key 是否正确配置。
使用命令验证：
```bash
kubectl config view
```
检查 clusters 和 users 字段是否匹配你的 kind 集群配置。
API Server 监听状态：
确认 API Server 是否在容器内监听 34100 端口，以及监听的 IP 地址。
在 kind 控制平面容器内运行：
```bash
docker exec -it <kind-control-plane-container> bash
netstat -tuln | grep 34100
```
确保 API Server 监听在 0.0.0.0:34100 或正确的 IP。
Docker 端口映射：
确认 kind 集群的端口映射是否正确配置。kind 通常通过 --port 参数暴露 API Server 端口。
检查 Docker 端口映射：
```bash
docker ps | grep kind
docker port <kind-control-plane-container>
```
确保 34100 端口正确映射到宿主机的 34100。
TLS 版本和加密套件兼容性：
kubectl 和 API Server 可能因 TLS 版本（如 TLS 1.2 vs TLS 1.3）或加密套件不匹配而失败。
使用 curl 测试 TLS 连接并指定协议：
```bash
curl --tlsv1.2 --verbose https://localhost:34100
curl --tlsv1.3 --verbose https://localhost:34100
```
查看是否返回具体的 TLS 错误。
证书链验证：
检查 API Server 的证书是否有效且可被客户端信任。
使用 openssl s_client 更详细的命令：
```bash
openssl s_client -connect localhost:34100 -showcerts -debug
```
检查返回的证书链、错误信息（如 self signed certificate 或 unable to get local issuer certificate）。
mTLS 配置：
默认情况下，Kubernetes API Server 不启用 mTLS，但如果 kind 集群被自定义配置为要求客户端证书，可能会导致握手失败。
检查 kind 配置文件（通常在 ~/.kind/<cluster-name>）或 API Server 的启动参数：
```bash
docker exec -it <kind-control-plane-container> ps aux | grep kube-apiserver
```
查看是否包含 --client-ca-file 或其他 mTLS 相关参数。
容器日志：
检查 kind 控制平面容器的日志，查找 API Server 的 TLS 相关错误：
```bash
docker logs <kind-control-plane-container>
```
搜索关键词如 TLS, handshake, certificate。
### 调试步骤
以下是推荐的调试步骤，按优先级排序：
验证 kubeconfig 配置：
运行以下命令检查 kubeconfig：
bash
kubectl config view --raw
确保 server 指向 https://localhost:34100（或正确的宿主机 IP）。
如果 certificate-authority-data 存在，解码查看 CA 证书：
```bash
echo "<certificate-authority-data>" | base64 -d > ca.crt
openssl x509 -in ca.crt -text -noout
```
如果需要客户端证书，确认 client-certificate-data 和 client-key-data 有效。
检查 Docker 网络和端口：
确认 kind 集群的端口映射：
```bash
docker port <kind-control-plane-container>
```
测试宿主机到容器的连接：
```bash
nc -zv localhost 34100
```
如果失败，检查 kind 配置文件（kind.yaml）中是否正确设置了 apiServerPort：
```yaml
apiServerAddress: "0.0.0.0"
apiServerPort: 34100
```
深入 TLS 调试：
使用 openssl s_client 获取详细 TLS 信息：
```bash
openssl s_client -connect localhost:34100 -tls1_2 -showcerts -debug
```
检查错误信息，如：
verify error:num=20:unable to get local issuer certificate：CA 证书缺失或不匹配。
sslv3 alert handshake failure：加密套件或 TLS 版本不兼容。
如果获取不到证书，尝试用 tcpdump 捕获 TLS 流量：
```bash
sudo tcpdump -i lo port 34100 -w tls.pcap
```
然后用 Wireshark 分析握手过程。
检查 API Server 配置：
进入 kind 控制平面容器，查看 API Server 配置：
```bash
docker exec -it <kind-control-plane-container> bash
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```
检查 --tls-cert-file、--tls-private-key-file 和 --client-ca-file 参数。
验证证书文件是否存在且有效：
```bash
openssl x509 -in <path-to-tls-cert-file> -text -noout
```
测试 mTLS 可能性：
如果怀疑是 mTLS 导致，尝试在 kubectl 命令中显式提供客户端证书：
```bash
kubectl --client-certificate=<client-cert.pem> --client-key=<client-key.pem> get nodes
```
检查 API Server 是否要求客户端证书：
```bash
docker exec -it <kind-control-plane-container> grep client-ca-file /etc/kubernetes/manifests/kube-apiserver.yaml
```
如果存在 --client-ca-file，说明启用了 mTLS。
重置 kind 集群：
如果以上步骤无法定位问题，考虑删除并重新创建 kind 集群：
```bash
kind delete cluster --name <cluster-name>
kind create cluster --name <cluster-name> --config kind.yaml
```
使用简单的 kind.yaml 配置：
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 34100
```
### mTLS 可能性及调试
mTLS 是否可能导致问题？
默认情况下，kind 创建的 Kubernetes 集群不启用 mTLS，API Server 仅要求服务器证书，客户端通过 CA 验证服务器身份。
但是，如果 kind 集群被自定义配置（例如通过修改 kube-apiserver 参数），可能启用了 mTLS，要求客户端提供证书。
你的现象（Client Hello 后握手被关闭）可能是 API Server 期望客户端证书但未收到。
如何调试 mTLS？
检查 API Server 配置：
查看 kube-apiserver 是否配置了 --client-ca-file：
```bash
docker exec -it <kind-control-plane-container> grep client-ca-file /etc/kubernetes/manifests/kube-apiserver.yaml
```
如果存在，说明需要客户端证书。
验证客户端证书：
检查 kubeconfig 中的 client-certificate 和 client-key 是否存在且有效：
```bash
kubectl config view --raw
```
如果缺失，尝试从 kind 集群获取默认客户端证书：
```bash
ls ~/.kind/<cluster-name>
```
通常包含 ca.crt、client.crt 和 client.key。
测试带客户端证书的连接：
使用 curl 测试 mTLS：
```bash
curl --cacert ca.crt --cert client.crt --key client.key https://localhost:34100
```
如果成功，说明需要配置 kubectl 使用这些证书：
```bash
kubectl --client-certificate=client.crt --client-key=client.key get nodes
```
禁用 mTLS（如果不需要）：
如果确认 mTLS 不必要，编辑 kube-apiserver 配置，移除 --client-ca-file 参数：
```bash
docker exec -it <kind-control-plane-container> vi /etc/kubernetes/manifests/kube-apiserver.yaml
```
删除 --client-ca-file 行，重启 API Server：
bash
```
docker restart <kind-control-plane-container>
```
### 总结与建议
最可能的原因：
kubeconfig 中证书配置错误（如 CA 证书缺失或不匹配）。
API Server 的 TLS 证书无效或端口映射错误。
mTLS 配置导致客户端证书缺失（可能性较低，但需排除）。
优先调试步骤：
验证 kubeconfig 配置，确保 server 和证书正确。
使用 openssl s_client 检查 TLS 握手详细错误。
检查 Docker 端口映射和 API Server 监听状态。
确认是否启用了 mTLS（检查 --client-ca-file）。
快速验证：
尝试用 curl 测试：
```bash
curl --cacert <ca.crt> --verbose https://localhost:34100
```
如果失败，重点检查证书和端口映射。
### 最后手段：
如果问题仍未解决，备份 kind 配置，删除并重新创建集群，确保使用默认配置。
如果需要进一步协助，请提供以下信息：

```
kubectl config view --raw 的输出（敏感信息可掩盖）。
docker port <kind-control-plane-container> 的输出。
openssl s_client -connect localhost:34100 的完整错误日志。
```
kind 集群的配置文件（kind.yaml）。
希望这些建议能帮助你解决问题！
