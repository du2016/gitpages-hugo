---
title: "从零搭建一个基于GitHub Pages的博客"
date: 2017-12-19T16:41:01+08:00
draft: false
thumbnailImage: /img/hugo.png
thumbnailImagePosition: left
categories:
- others
tags:
- gitpage
- travis-ci
- hugo
---

抽时间搭了一个基于GitHub Pages的博客，本文记录一下选用中用到的东西和细节。

# 组件

- godaddy [域名注册](https://sg.godaddy.com/zh) 
- github pages
- hugo [hugo中文站](http://www.gohugo.org/) [hugo官网站](http://gohugo.io/)
- disqus [disqus](https://disqus.com)
- gitment [gitment](https://imsun.net/posts/gitment-introduction)
- 免费全站https+cdn [cloudflare](http://cloudflare.com)
- [travis-ci](https://travis-ci.org/)

# 域名注册

域名注册不再讲述，大家都是搞IT的应该都搞过。

# 配置github pages
创建一个仓库以自己的用户名开头 例 du2016.github.io
在该repo的配置中设置域名以及分组等信息

# 安装hugo

MAC快捷安装

```
brew install hugo
```

访问github获取最新版本

```
https://github.com/gohugoio/hugo/releases
```

生成站点
```
hugo new site mysite
```

选择[hugo主题](https://themes.gohugo.io/)
我使用的是`hugo-tranquilpeak-theme`
```
cd mysite
rm -rf config.toml  content/     static/
git clone https://github.com/kakawait/hugo-tranquilpeak-theme.git themes/hugo-tranquilpeak-theme
cp -r themes/hugo-tranquilpeak-theme/{config.toml,content,static} ./
```
编辑 config.toml填写个人站点信息

添加文章
```
hugo new post/install-conduit-on-k8s.md
```
创建的文章`draft: true`属性，即为草稿，如要发表该文章请改为false

添加分类
```
categories:
- servicemesh
```

添加标签
```
tags:
- Conduit
```

聚合文章
```
hugo
```

预览
```
hugo server
```

# 留言板

### disqus

Disqus是一家第三方社会化评论系统，主要为网站主提供评论托管服务。使用disqus需要评论者有disqus账号，不推荐，并且速度比较慢
该主题默认的留言板使用的留言板为`disqus`，若要使用disqus,访问[disqus网站](https://disqus.com/)进行注册，获取disqus shortname，修改config.toml中的disqusShortname配置。

### gitment

gitment是[imsun](https://github.com/imsun/gitment)大神写的基于github oauth的评论系统，搞技术的相信github账号大家都是有的，比较实用。

[这里](https://imsun.net/posts/gitment-introduction/#more)是作者写的如何使用gitment搭建博客系统的文章。

使用gitment需要在github上面生成[oauth id](https://github.com/settings/applications/new),需要注意的是Authorization callback URL和Homepage URL都要写上你网站对应的真实url例如我的https://du2016.github.io。

gitment模板配置
```
cat >> ./themes/hugo-tranquilpeak-theme/layouts/partials/gitment.html <<EOF
<div id="container"></div>
<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<script>
var gitment = new Gitment({
  owner: 'du2016',
  repo: 'du2016.github.io',
  oauth: {
    client_id: 'xx',
    client_secret: 'xxx',
  },
})
gitment.render('container')
</script>
EOF
```

编辑themes/hugo-tranquilpeak-theme/layouts/_default/single.html模板文件嵌套gitment的模板，假如想要设置评论开关，可以在 config.toml中添加全局配置或在对应文件标题添加特殊配置，然后根据golang 模板语法进行判断。

# 使用cloudflare实现全站https及cdn
现在大家都上全站https，谷歌都标记http页面为不安全了，再使用http岂不是很low，不符合我们高大上的身份。这里我们选用cloudflare，提供免费的https和cdn，支持http强制跳转。

在使用cloudflare之前我们需要先将我们的解析指向cloudflare。

```
naomi.ns.cloudflare.com
todd.ns.cloudflare.com
```

### 添加解析

注册cloudflare账号，添加你的网站，不搞其他东西的话加一个www再加一个主域的cname就可以了，都解析到你的github pages域名,这里可以选择是否使用http proxy即cdn，不用白不用，速度还挺快。

### 启用https

选择crypto选项卡
设置ssl on,Always use HTTPS on

### cdn缓存设置
选择caching选项卡
Purge Cache可以手动清楚缓存。
Always Online 将会在源站不可用的时候返回一个cloudflare页面，根据情况选择是否启用。


# travis-ci

travis-ci是一个基于github的持续集成工具，可以在更新代码后自动编译，推送代码。这里我用来在推送hugo 站点源代码后自动构建推送到我的github page。

使用github账号登录travis-ci，点击accounts选择你要构建的repo
使用travis-ci需要配置.travis.yml来指定我们使用的语言、系统环境版本，以及操作步骤，每个镜像在没有给出构建参数时会有默认操作，详细信息可以查看[官方文档](https://docs.travis-ci.com/)

为了让travis-ci有push的能力，我们需要添加sshkey加密，具体参见https://zespia.tw/blog/2015/01/21/continuous-deployment-to-github-with-travis/

在readme里面加一行[![Build Status](https://travis-ci.org/du2016/gitpages-hugo.svg?branch=master)](https://travis-ci.org/du2016/gitpages-hugo) 就可以展示build状态，有木有很爽。


欢迎加入QQ群：k8s开发与实践（482956822）一起交流k8s技术