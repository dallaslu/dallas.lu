---
title: Spring MVC 与独立应用共享 Context
date: '2017-01-02 23:34'
author: 'dallaslu'

taxonomy:
    category:
        - Software
    tag:
        - Java
        - Spring
        - Spring-mvc

---
C/S 架构的服务端使用了 Spring 框架，同时需要一个可拆卸的组件来提供基于 http 的 web API。接口依赖于原来的业务，所以希望 Spring MVC 框架能够利用原有的 Spring 中的 applicationContext。

===

## 独立配置 Spring MVC

因为 API 并非必要业务，可能会被关掉，所以放弃了使用 `XmlWebApplicationContext` 来替换原有的 `XmlApplicationContext`。创建了一个新包，使用注解的方式来配置启用 Spring MVC。`SpringWebConfig.java` ：

```java
package com.dallaslu.spring.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@Configuration
@EnableWebMvc
@ImportResource({"classpath*:/applicationContext.xml"})
public class SpringWebConfig {
}
```

在 `applicationContext.xml` 中配置了业务类的扫描包路径：

```xml
&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;beans xmlns="http://www.springframework.org/schema/beans"
 xmlns:context="http://www.springframework.org/schema/context"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="
 http://www.springframework.org/schema/context
 http://www.springframework.org/schema/context/spring-context.xsd
 http://www.springframework.org/schema/beans
 http://www.springframework.org/schema/beans/spring-beans.xsd"&gt;

 &lt;context:component-scan base-package="com.dallaslu.spring.web"/&gt;

&lt;/beans&gt;
```

然后在网络处理模块中进行初始化，准备将请求转发给 Spring MVC 来处理，`WebServer.java`：

```java
// ...
MockServletContext servletContext = new MockServletContext();
MockServletConfig servletConfig = new MockServletConfig(servletContext);

AnnotationConfigWebApplicationContext wac = new AnnotationConfigWebApplicationContext();
wac.setServletContext(servletContext);
wac.setServletConfig(servletConfig);
wac.register(SpringWebConfig.class);
wac.refresh();

DispatcherServlet dispatcherServlet = new DispatcherServlet(wac);
dispatcherServlet.init(servletConfig);
// ...
```

以上配置单独运行没有问题，然而和原有的 Spring 一起运行时就会报出无法构建 bean 的异常信息。

## 保持 Spring MVC 独立

最终发现，类 `SpringWebConfig` 所在的包路径，处在原有 Spring 的扫描范围中，导致 MVC 提前被 `XmlApplicationContext` 初始化了。所以移除了类中的 `@EnableWebMvc` 注解，并在 mvc 的 xml 中加入 `&lt;mvc:annotation-driven /&gt;` ，来保证 mvc 在预期的时机，被正确的初始化。

## 使用 setParent 来整合上下文

尽管 web 模块可以正常运行，但是并不能通过 Spring 来自动装配所需的业务类。将 MVC 的启动代码移入到 init 方法中，并加入了 `@PostConstruct` 注解，预期在应用启动之后进行初始化。并使用 `wac.setParent(applicationContext)` 来合并上下文。

这次服务器应用与依赖原有业务的 web 模块都正常启动了，服务器也的确收到了访问请求，然而页面时却一直没有响应信息。经过逐步跟踪，定位到 Spring 在派发 servlet 的处理结果事件时，发生了死锁。

## 在 applicationContext 完全启动后再初始化 MVC

经过多次尝试，将 mvc 的启动移到没有 `@PostConstruct` 注解的单独方法中，并在 `applicationContext` 完全初始化后再进行调用：

```java
ApplicationContext applicationContext = new ClassPathXmlApplicationContext("context-application.xml");
WebServer webServer = applicationContext.getBean(WebServer.class);
webServer.setBeanFactory(applicationContext);
webServer.start();
```

这次完全正常了。不知使用 `default-lazy-init` 是否能够解决这个问题，若有读者实践后还请告之。
