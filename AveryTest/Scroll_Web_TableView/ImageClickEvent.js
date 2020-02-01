var imgs = document.getElementsByTagName("img");  // 获取所有img标签
var imgUrls = new Array(); //获取所有的imgUrl
var x = 0; var y = 0; var width = 0; var height = 0;

for (var i = 0; i < imgs.length; i++) {
    var img = imgs[i];
    if (img.src || img.getAttribute('data-src')) {  // 如果图片链接存在
        imgUrls.push(img.src || img.getAttribute('data-src'));  // 添加到图片链接数组中
        // 如果图片没有默认的onclick事件，且父元素不是a标签，则添加onclick事件，当用户点击时，把图片链接回传给Native
        if (!img.onclick && img.parentElement.tagName !== "A") {
            img.index = i;  // 给图片添加下标的属性
            img.onclick = function() {  // 添加点击事件，并且回传选中的图片链接、下标、屏幕上的位置、全部的图片数组等
                x = this.getBoundingClientRect().left;
                y = this.getBoundingClientRect().top;
                x = x + document.documentElement.scrollLeft;
                y = y + document.documentElement.scrollTop;
                width = this.width;
                height = this.height;
                var imgInfo = {
                    imgUrl: this.src || this.getAttribute('data-src'),
                    x: x,
                    y: y,
                    width: width,
                    height: height,
                    index: this.index,
                    imgUrls: imgUrls
                };
                h5ImageDidClick(imgInfo);
            }
        }
    }
}

function h5ImageDidClick (info) {
    window.webkit.messageHandlers.imageDidClick.postMessage(info);
}
