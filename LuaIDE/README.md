这是一款lua编辑器，提供工程项目管理代码，自动提示补全功能，以及各种自定义功能。

具体功能如下：
1、提供自定义关键字
2、提供自定义接口自动提示
3、提供关键字、接口颜色自定义
4、提供Lua语法检查和编译、调试
5、接口快速定位
6、提供注释自动提示
?

[API]
KEY     =/api/luakey.api;/api/userkey.api(用户可自己添加自己关键字)
LIB     =/api/lualib5.api (用户可自己添加自己系统接口)
USER    =/api/entity.api;/api/particle.API;/api/rss.api;/api/map.api;/api/Game.api;/api/ToServer.api;/api/UIWnd.api;/api/zone.api;(用户可自己添加自己的接口)

[COLOR]
KEY       =16711680 (关键字颜色)
LIB       =8421376  (系统接口颜色)
USER      =12615935 (用户接口颜色)
USERLOCAL =16744448 (用户局部接口颜色)
USERGLOBAL=33023    (用户全局接口颜色)
COMMENT   =32768    (注释颜色)
OPERATOR  =16711935 (操作符颜色)
NUMBER    =8421376  (数字颜色)


[FONT]
NAME =Arial          (字体类型)
SIZE =12             (字体大小)

自动提示里可加入说明文字，以"/*"开始。


