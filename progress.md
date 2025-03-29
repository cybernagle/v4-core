
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
