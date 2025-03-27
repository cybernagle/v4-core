
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

