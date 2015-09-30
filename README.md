#KSEnitity

KSEntity是以数据实体为中心，围绕实体打造的json实体转换的网络库。以往的网络库是庞大并且突出，KSEntity弱化了网络库的存在感，站在实体的角度来考虑问题。将网络数据看成不同形式的实体，可以一键拉取并且转化，相对于过程来说更强调结果。
##发送请求

发送请求，需要一个任意实体，然后添加必要的参数，调用-sendRequestFinish:方法,就可以发送请求，并且得到一个解析好的实体。

```
    EntityTest *test = [[EntityTest alloc]init];

    test.requestUrlStringKS = @"http://ip.taobao.com/service/getIpInfo.php";
    test.requestParamsKS= @{@"ip":@"63.223.108.42"};
    [test sendRequestFinish:^(BOOL isSuccess, NSError *err) {
         if (isSuccess) {
             //do something
         }else{
            NSLog(@"%@",[err localizedDescription]);
        }
    }];
```
##异步多个请求同时发送

开发中，常常遇到一个页面同时发送多个请求，如果串行则相对较慢，并行则要写一些同步的代码。KSEntity为该问题提供了解决方案。
```
    NSMutableArray *array=[[NSMutableArray alloc]init];
    
    for (int i=0; i<100; i++) {
        EntityTest *test = [[EntityTest alloc]init];
        test.requestUrlStringKS = @"http://ip.taobao.com/service/getIpInfo.php";
        test.requestParamsKS= @{@"ip":@"63.223.108.42"};
        [array addObject:test];
    }
    [array sendRequestFinish:^(BOOL isSuccess, NSError *err, NSUInteger index) {
        if (isSuccess) {
          //do something
        }else
        {
            NSLog(@“%ld-%@",index,[err localizedDescription]);
        }
    }];
```
isSuccess判断全部请求发送是否成功，否则，err为错误信息，index为数组中错误的数据下标。

##除此之外的一些功能特性

KSEntity支持

###1. 失败重新发送

无需再另写一遍发送请求的调用代码。

失败自动重新再次尝试发送同样的请求，直到成功为止。

你可以设置最大尝试次数。

`[KSRequestManager manager].tryCount=2;`

###2. 断点续传

`test.supportBreakPointContinueTransfer=YES;`

###3.取消请求

`[test cancelRequest];`

如果你想取消正在进行的全部网络请求

`[[KSRequestManager manager] cancelAllRequest];`

###4.网络缓存

缓存使用的是系统的NSURLCache

你可以在KSRequestManager中设置开启、缓存大小、或者缓存策略。

###5.支持https网络请求

因为杂牌证书是ios识别不了的，所以当有证书的时候会询问，是否继续，选择继续的话会跳过手机端的证书验证，从而继续后面的动作。

---

##json解析

当我们用一个实体发送了请求，如果请求成功，那么这个实体是已经被解析好了的。

方法是使用RUNTIME 遍历实体的属性，再找到对应的json键值对，属性需要和key值保持一致。所有的其他解析大概都是这个原理。

同样，我们支持属性映射，如果key值的名字是你不喜欢的，或者不符合你的编码规范，再或者使用了系统关键字，你的属性无法定义同样的名字。我们可以给你多一个选择。

`[EntityTest setNetMapping:@{@"ip":@"addr"}];`

这样json中如果有key为ip的数据，就会自动赋给属性名字为addr的属性。

###级联解析

现在对于嵌套的数据有了很好的支持。

如果你的属性中存在自定义的类型，那么KSEntity会自动识别出来并且跟进这个自定义的类型，将它解析出来。


---

##有问题反馈
在使用中有任何问题，欢迎反馈给我，可以用以下联系方式跟我交流

感谢大家的支持，网络只是第一部分，后续会有数据库与实体转换的部分整合进来，敬请期待。

* QQ:  393858338
* 邮箱: hty393858339@163.com

##作者
* HTY 

