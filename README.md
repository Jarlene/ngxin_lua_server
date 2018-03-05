# ngxin_lua_server
a common nginx server 

---
## 配置

在conf文件夹中，主要是配置一些基本常量，

 - runtime.lua 文件配置运行时的环境，和数据库
 - catelog.lua 配置路径，用于解析module和方法
 - constant.lua 是一些常量配置
 - database.lua 是配置数据库环境
 - redis.lua 是配置redis环境
 - returncode.lua 是配置返回结果码
 

## 通用代码
comm文件夹中是一些通用的代码，方便用户使用，比如http中就包含了一些获取请求参数或者请求cookie等信息

## 业务代码
业务代码主要放在ui中，例如ui/user.lua文件主要是针对用户属性的，比如登录，检查相关的状态或者查询某些收藏或者其他的
 
## index.lua

主要负责路由，将发送来的请求发送到ui中各个文件中，进行请求。