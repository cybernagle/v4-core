
## 20250324

现在的进度是， 我在执行 deploy.sol 的时候， poolManager 直接传入 50000 是不行的， 估计是要传入一个地址之类的。

## 20250325
只有十分钟的工作， pollmanager 的问题仍然没有解决。而且花了很长的时间找到如何启动本地测试网络。 现在要记住， anvil 就是在本地启动测试网络；接下来仍然要继续赵 deploy.sol 的 poolManager 问题；


## 20250326


今天在墙上用的时间 take 了 20 min；很沮丧。

anvil 启动网络后， 将 50000 修改成 address(this) 正常通过编译。  
但是仍然被 warning 了。  
具体报错是 size 太大， 需要优化， 这个是因为 eth 网络的限制合约大小的缘故，目前没有去解决；  

第二个是我希望有一个 ether scan 的site， 这样通过 ui 来观察更加直观。  
另外，本地 clone 了 uniswap interface， 这样， 我就能够类似offical 的站点一样的操作。  
今天的进度是 clone 了这个 repo， 执行了 npm install, 还是报错了；  
    > Unsupported URL Type "workspace" : workspace:^

然后问了 kimi 要了 guide ，下次 follow kimi 好了。  


## 20250327

太晚了， 现在是凌晨 0：28 了。  
刚刚把 deploy.s.sol 部署在本地测试网络。但是 trans 失败掉了。没有看原因。后面需要看一下。  
另外，本地跑了一个进程装 yarn ，workspace:^ 的报错是因为 config 是不支持 npm install， 需要使用 yarn 来操作。  


下一次开始就是弄清楚 deploy.s.sol 的逻辑是什么，uni core 似乎并没有被部署。managepool 也没有被部署。我有一些 confuse；  
第二个就是尽力把 unisap interface 的跑起来。这样，就能够使用 ui 来 operate 本地测试网络。  
有了前面两个步骤， 就可以考虑看看怎么玩 v4 的 hook 了；  


## 20250328

uniswap-interface 使用 yarn install 看起来是可以的。  
> npm install -g yarn
> yarn install

接下来， 我要找到 yarn 的 proxy ， 因为网络又出问题了... fuck...  
另外， sol 的脚本我还是没有能够很理解，需要花一点时间单独理解一下。  



## 20250329


1. 今天找到了一个叫做 blockcount 项目用于 visualize 本地测试网络, 使用 docker compose up 目前看起来是启动起来了，使用 docker ps 查看了， blockcount 项目本身（后端）一直在重启。所以也无法访问。下一个调研可以从这里开始。stop 掉了，明天再看。
2. uniswap interface 使用 yarn web start 来启动， 但是显然，连接到错误的网络， 提示 key 不存在。应该需要配置一下。
3. 接上面的问题，在 .env.defaults 里面添加了 REACT\_APP\_NETWORK\_URLS:{} / REACT\_APP\_CHAIN\_IDS 都无法工作。应该还需要更细节的调研


## 20250331

1. 紧接着 20250329-01 问题。gpt 提示说是 file notfound 问题。
> blockcount 启动的时候 anvil 模式的时候， backend 有如下报错： (Code.LoadError) could not load /app/apps/explorer/config/prod/anvil.exs. Reason: enoent
enoent 代表的意思是 file notfound。
目前没有线索，会需要一点时间来测试了。

#### uniswap interface 启动

interface 启动成功了。 [原因](https://github.com/Uniswap/interface/issues/7678?ref=sanghun.xyz)是 .env.defaults 里面没有对应的变量。启动成功后就解决了。 
现在的问题就是
1. 某个 ts 文件当中导入 ui 失败了。
2. 连接的网络是 offical 的网络， 数据都是实时的。并没有连接到我的测试网络中。



## 20250401 08:50 - 09:00

现在有两个问题：
1. blockcount 启动问题
2. uniswap interface 并没有接入本地网络。

#### 启动问题
报错如下：
- db                | chmod: changing permissions of '/var/run/postgresql': Operation not permitted
- stats             | 2025-04-01T00:52:28.617111Z ERROR update_charts{update_group="AverageBlockTimeGroup" update_time="2025-04-01 00:52:28.609093634 UTC"}: stats::data_source::kinds::local_db: error during updating chart: blockscout database error: Query Error: error returned from database: relation "blocks" does not exist chart=
- stats             | 2025-04-01T00:52:28.617863Z ERROR stats_server::update_service: error during updating group: blockscout database error: Query Error: error returned from database: relation "blocks" does not exist update_group="AverageBlockTimeGroup"
- stats             | 2025-04-01T00:52:28.631225Z ERROR update_charts{update_group="PendingTxns30mGroup" update_time="2025-04-01 00:52:28.628754995 UTC"}: stats::data_source::kinds::local_db: error during updating chart: blockscout database error: Query Error: error returned from database: relation "blocks" does not exist chart=
- stats             | 2025-04-01T00:52:28.631326Z ERROR stats_server::update_service: error during updating group: blockscout database error: Query Error: error returned from database: relation "blocks" does not exist update_group=
- stats             | 2025-04-01T00:52:28.633020Z ERROR stats_server::update_service: error during updating group: blockscout database error: Query Error: error returned from database: relation "blocks" does not exist update_group="TotalAddressesGroup"
- stats             | 2025-04-01T00:52:28.634046Z ERROR update_charts{update_group="NewTxnsWindowGroup" update_time="2025-04-01 00:52:28.626939477 UTC"}: stats::data_source::kinds::local_db: error during updating chart: blockscout database error: Query Error: error returned from database: relation "blocks" does not exist chart=newTxnsWindow_DAY
>   backend           | ERROR! Config provider Config.Reader failed with:
    backend           | ** (Code.LoadError) could not load /app/apps/explorer/config/prod/anvil.exs. Reason: enoent
    backend           |     (elixir 1.17.3) lib/code.ex:2158: Code.find_file!/2
    backend           |     (elixir 1.17.3) lib/code.ex:1483: Code.require_file/2
    backend           |     config/runtime/prod.exs:112: (file)
    backend           |     (elixir 1.17.3) src/elixir_compiler.erl:77: :elixir_compiler.dispatch/4
    backend           |     (elixir 1.17.3) src/elixir_compiler.erl:52: :elixir_compiler.compile/4
    backend           |     (elixir 1.17.3) src/elixir_compiler.erl:39: :elixir_compiler.maybe_fast_compile/2
    backend           |     (elixir 1.17.3) src/elixir_lexical.erl:15: :elixir_lexical.run/3
    backend           | 
    backend           | Runtime terminating during boot ({#{message=><<"could not load /app/apps/explorer/config/prod/anvil.exs. Reason: enoent">>,reason=>enoent,file=><<"/app/apps/explorer/config/prod/anvil.exs">>,'__struct__'=>'Elixir.Code.LoadError','__exception__'=>true},[{'Elixir.Code','find_file!',2,[{file,"lib/code.ex"},{line,2158}]},{'Elixir.Code',require_file,2,[{file,"lib/code.ex"},{line,1483}]},{elixir_compiler_1,'__FILE__',1,[{file,"config/runtime/prod.exs"},{line,112}]},{elixir_compiler,dispatch,4,[{file,"src/elixir_compiler.erl"},{line,77}]},{elixir_compiler,compile,4,[{file,"src/elixir_compiler.erl"},{line,52}]},{elixir_compiler,maybe_fast_compile,2,[{file,"src/elixir_compiler.erl"},{line,39}]},{elixir_lexical,run,3,[{file,"src/elixir_lexical.erl"},{line,15}]}]})

目前就收集到如上报错， 下次再看。

## 20250401 21:30 - 21:51



我怀疑上面的问题都是因为网络导致的，所以我的解决思路就是，修改 compose 的 host。  
另外， 我准备安装一个 kind 在本地用于 kubernetes 环境的测试。  
这样我用起来会比较熟悉。  

kind 目前还在启动。只能等等了；

没有什么进度；


## 20250407 20:41 - 20:48

准备全部迁移 k8s 环境。

1. kubectl
2. avnil env
3. uniswap-interface
4. blockcounts


安装了 kubectl + checksum成功了，下一步在上面安装blockcounts  
女儿找我， 先去陪她了。


## 20250408 09:00 - 09:10


kind get cluster 可以工作， 但是 kubectl get 就不可以了  
又引入了新的问题...  

进度：  
进入 docker 后， 校验了  
`kubeadm certs check-expirations`  
但是证书都没有过期  

下面的思路是 kubctl 的 config 为和会导致 tls 握手失败。  



## 20250409 

安装了 fzf， 有一个 key binding 竟然存储在了 /usr/share/docs 里面了。神奇；  
在 `.zshrc` 文件当中添加了 `source /key-binding-path/key-binding`, 问题被解决了；  

kubectl 的问题，证书都已经校验过了，没有过期，怀疑是 docker 和 node 的日期不一致引起的。  
接下来修改一下 timezone ， 然后重启试试看；


openssl s_client connect 也不工作。 没有什么思路 ...  


## 20250411 08:45 - 09:00

```shell
nc -zv localhost port_number
```
结果正常， 所以端口是通的；


```shell
openssl s_client -connect 127.0.0.1:41637
```
一直卡着，不知道原因。

剩下的选项：  
1. 检查证书 match 问题。（讲道理不会的， 因为 kubeconfig 就是 kind 提供的）
2. 抓包看细节。

deepseek 提供了几个意见， 下一次 follow 一下；  


## 20250417 0849 - 09114

尝试了 deepseek 的解决方案，无法工作。  

考虑下载 wireshark 抓包看看效果。  

抓到包了 `sudo tcpdump -i any -w output.pcap port 33701`

1. 目前 tls 连接的建立在 client hello 后就被关闭了；  
2. openssl 硬编码协议为 tls1_1 ， 连接貌似成功了。 下次检查一下。

## 20250418 0849 - 09114

还在 debug tls 建立连接的问题。  

补充一下， 不是添加了版本就工作了，而是 sudo + tls1\_1 才工作的。  
sudo openssl s\_client tls1\_1 并不是因为可以工作， 而是前面  
> 4097F0FBA6770000:error:0A0000BF:SSL routines:tls_setup_handshake:no protocols available:../ssl/statem/statem_lib.c:104:

没有 protocol 从而导致后面可以执行。  
所以，现在可以推测是前面在对应的 ssl 版本执行的时候，卡住了。  


## 20250421 0857 - 0912


nmap 来看看加密套件；  

没有什么进展，太依赖 llm 了， 刚刚去 github 上面发现不少的 issue 关于类似的问题。  


https://github.com/kubernetes-sigs/kind/issues/2542

https://github.com/kubernetes-sigs/kind/issues/2879

https://github.com/kubernetes-sigs/kind/issues/3403
