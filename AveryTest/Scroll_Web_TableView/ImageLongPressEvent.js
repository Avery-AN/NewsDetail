var imgs = document.getElementsByTagName("img");  // 获取所有img标签
var imgUrls = new Array();  // 获取所有的imgUrl

for (var i = 0; i < imgs.length; i++) {
    img = imgs[i];
    img.index = i;  // 给图片添加下标的属性
    
    // 添加触摸事件
    img.addEventListener('touchstart', function(event) {
        /**
         // 保存触摸点处的x、y轴坐标
         touch = event.touches[0];
         var touch = event.targetTouches[0];  // touches数组对象获得屏幕上所有的touch，取第一个touch
         startPos = {x:touch.pageX,y:touch.pageY,time:+new Date}; //取第一个touch的坐标值
        */

        var imgInfo = {
            imgUrl: this.src || this.getAttribute('data-src'),
            index: this.index
        };
        // 设置定时器，js没长按事件，就是使用定时器实现的，800毫秒后触发，img.src为图片地址，这里可以拿到后做保存图片发大图等功能
        // setTimeout(function, milliseconds, param1, param2, ...)
        timeout = setTimeout(h5ImageDidLongpress, 800, imgInfo);
    });
    
    // 移动事件:
    img.addEventListener('touchmove', function(event) {
        // touch = event.touches[0];
        // event.preventDefault();
        clearTimeout(timeout);
    });
    
    // touch结束时取消定时器:
    img.addEventListener('touchend', function(event) {
        clearTimeout(timeout);
    });
    
    // touch取消时取消定时器:
    img.addEventListener('touchcancel', function(event) {
        clearTimeout(timeout);
    });
}

function h5ImageDidLongpress(info) {
    window.webkit.messageHandlers.imageDidLongpress.postMessage(info);
}
