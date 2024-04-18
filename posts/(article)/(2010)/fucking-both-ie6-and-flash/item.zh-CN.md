---
title: 不堪的IE6与Flash
date: '2010-04-15 18:47'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - Flash
        - IE

---
我是个ActionScript 2的门外汉，最近在硬着头皮做Flash。其中有个剪辑需要水平平滑移动。写好代码之后，测试正常。到IE中一看，移动速度却慢得像蜗牛。

===

原来的代码类似这样：

```javascript
clearInterval(moveTimer);
moveTimer = setInterval(doMove,10);

function doMove(){
	item._x += 90;
	if( item._x >= 8964){
		clearInterval(moveTimer);
		// do something else
	}
}
```

一直知道经常需要为 IE6 编写多余的 JavaScript、CSS 。没想到 AS 也是。这个移动速度问题，可能是 IE6 的处理效率低的缘故。本来对于移动速度没有特别的要求，流畅、迅速即可。情况特殊，也不适合用帧来处理。

于此同时，也发现利用 setInterval 来实现的计时器，在IE6 中也极不准确。后来无奈，改用算时方式，指定时间与运动距离：

```javascript
var moveStartTime:Number = getTimer();
var millsecond:Number = 1000;

clearInterval(moveTimer);
moveTimer = setInterval(doMove,10);

function doMove(){
	var timePast = getTimer() - moveStartTime;
	var distance = (8964/millisecond) * timePast;

	if( distance > 8964){
		item._x = 8964;
		clearInterval(moveTimer);
		// do something else
	}else{
		item._x = distance;
	}
}
```

IE6 真是让人情何以堪哪。最近用上了 mg12 的 [kill ie6](http://www.neoease.com/lets-kill-ie6/) Widget。同时发现，我的博客竟然一直以来在IE6中是裸奔状态，嗯，我也不大清楚是怎么回事儿，等有空再琢磨吧。
