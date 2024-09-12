---
layout: post
category: 前端
title: "jquery-ajaxFileUpload插件"
tag: [web, js]
excerpt: 用于浏览器异步上传文件。
---

## 介绍

用于浏览器异步上传文件。

## 下载地址

[https://github.com/carlcarl/AjaxFileUpload](https://github.com/carlcarl/AjaxFileUpload)

语法：

```html
$.ajaxFileUpload([options])
```

### options参数说明：

```html
url           上传处理程序地址。　　
fileElementId 需要上传的文件域的ID, 即<input type="file">的ID。
secureuri     是否启用安全提交, 默认为false。 
dataType      服务器返回的数据类型。 可以为xml,script,json,html。如果不填写, jQuery会自动判断。
success       提交成功后自动执行的处理函数, 参数data就是服务器返回的数据。
error         提交失败自动执行的处理函数。
data          自定义参数。 这个东西比较有用, 当有数据是与上传的图片相关的时候, 这个东西就要用到了。
type          当要提交自定义参数时, 这个参数要设置成post
```

### 错误提示:

```html
SyntaxError: missing ; before statement错误
  如果出现这个错误就需要检查url路径是否可以访问
SyntaxError: syntax error错误
  如果出现这个错误就需要检查处理提交操作的服务器后台处理程序是否存在语法错误
SyntaxError: invalid property id错误
  如果出现这个错误就需要检查文本域属性ID是否存在
SyntaxError: missing } in XML expression错误
  如果出现这个错误就需要检查文件name是否一致或不存在
其它自定义错误
  大家可使用变量$error直接打印的方法检查各参数是否正确, 比起上面这些无效的错误提示还是方便很多。
```

### 使用方法：

```html
<script src="jquery-1.7.1.js" type="text/javascript"></script>
<script src="ajaxfileupload.js" type="text/javascript"></script>
<body>
  <p><input type="file" id="file1" name="file" /></p>
  <input type="button" value="上传" />
  <p><img id="img1" alt="上传成功啦" src="" /></p>
</body>
<script type="text/javascript">
$(function () {
  $(":button").click(function () {
      ajaxFileUpload();
  })
})
function ajaxFileUpload() {
  $.ajaxFileUpload({
    url: '/upload.aspx', //用于文件上传的服务器端请求地址
    secureuri: false, //是否需要安全协议，一般设置为false
    fileElementId: 'file1', //文件上传域的ID
    dataType: 'json', //返回值类型 一般设置为json
    success: function (data, status) //服务器成功响应处理函数
    {
      $("#img1").attr("src", data.imgurl);
      if (typeof (data.error) != 'undefined') {
        if (data.error != '') {
            alert(data.error);
        } else {
            alert(data.msg);
        }
      }
    },
    error: function (data, status, e)//服务器响应失败处理函数
    {
      alert(e);
    }
  })
  return false;
}
</script>
```

源码

```html
jQuery.extend({
  createUploadIframe: function (id, uri) {
    //create frame
    var frameId = 'jUploadFrame' + id;
    var iframeHtml = '<iframe id="' + frameId + '" name="' + frameId + '" style="position:absolute; top:-9999px; left:-9999px"';
    if (window.ActiveXObject) {
      if (typeof uri == 'boolean') iframeHtml += ' src="' + 'JavaScript:false' + '"';
      else if (typeof uri == 'string') iframeHtml += ' src="' + uri + '"';
    }
    iframeHtml += ' />';
    jQuery(iframeHtml).appendTo(document.body);
    return jQuery('#' + frameId).get(0);
  },
  createUploadForm: function (id, fileElementId, data) {
    //create form
    var formId = 'jUploadForm' + id;
    var fileId = 'jUploadFile' + id;
    var form = jQuery('<form  action="" method="POST" name="' + formId + '" id="' + formId + '" enctype="multipart/form-data"></form>');
    if (data) {
      for (var i in data) {
        jQuery('<input type="hidden" name="' + i + '" value="' + data[i] + '" />').appendTo(form);
      }
    }
    var oldElement = jQuery('#' + fileElementId);
    var newElement = jQuery(oldElement).clone();
    jQuery(oldElement).attr('id', fileId);
    jQuery(oldElement).before(newElement);
    jQuery(oldElement).appendTo(form);

    //set attributes
    jQuery(form).css('position', 'absolute');
    jQuery(form).css('top', '-1200px');
    jQuery(form).css('left', '-1200px');
    jQuery(form).appendTo('body');
    return form;
  },
  ajaxFileUpload: function (s) {
    s = jQuery.extend({}, jQuery.ajaxSettings, s);
    var id = new Date().getTime()
    var form = jQuery.createUploadForm(id, s.fileElementId, (typeof(s.data) == 'undefined' ? false : s.data));
    var io = jQuery.createUploadIframe(id, s.secureuri);
    var frameId = 'jUploadFrame' + id;
    var formId = 'jUploadForm' + id;
    // Watch for a new set of requests
    if (s.global && !jQuery.active++) jQuery.event.trigger("ajaxStart");
    var requestDone = false;
    // Create the request object
    var xml = {}
    if (s.global) jQuery.event.trigger("ajaxSend", [xml, s]);
    // Wait for a response to come back
    var uploadCallback = function (isTimeout) {
      var io = document.getElementById(frameId);
      try {
        if (io.contentWindow) {
            xml.responseText = io.contentWindow.document.body ? io.contentWindow.document.body.innerHTML : null;
            xml.responseXML = io.contentWindow.document.XMLDocument ? io.contentWindow.document.XMLDocument : io.contentWindow.document;
        } else if (io.contentDocument) {
            xml.responseText = io.contentDocument.document.body ? io.contentDocument.document.body.innerHTML : null;
            xml.responseXML = io.contentDocument.document.XMLDocument ? io.contentDocument.document.XMLDocument : io.contentDocument.document;
        }
      } catch (e) {
        jQuery.handleError(s, xml, null, e);
      }
      if (xml || isTimeout == "timeout") {
        requestDone = true;
        var status;
        try {
            status = isTimeout != "timeout" ? "success" : "error";
            // Make sure that the request was successful or notmodified
            if (status != "error") {
              // process the data (runs the xml through httpData regardless of callback)
              var data = jQuery.uploadHttpData(xml, s.dataType);
              // If a local callback was specified, fire it and pass it the data
              if (s.success) s.success(data, status);
              // Fire the global callback
              if (s.global) jQuery.event.trigger("ajaxSuccess", [xml, s]);
            } else
              jQuery.handleError(s, xml, status);
        } catch (e) {
            status = "error";
            jQuery.handleError(s, xml, status, e);
        }
        // The request was completed
        if (s.global) jQuery.event.trigger("ajaxComplete", [xml, s]);
        // Handle the global AJAX counter
        if (s.global && !--jQuery.active) jQuery.event.trigger("ajaxStop");
        // Process result
        if (s.complete) s.complete(xml, status);
        jQuery(io).unbind()
        setTimeout(function () {
            try {
              jQuery(io).remove();
              jQuery(form).remove();
            } catch (e) {
              jQuery.handleError(s, xml, null, e);
            }
        }, 100)
        xml = null
      }
    }
    // Timeout checker
    if (s.timeout > 0) {
      setTimeout(function () {
        // Check to see if the request is still happening
        if (!requestDone) uploadCallback("timeout");
      }, s.timeout);
    }
    try {
      var form = jQuery('#' + formId);
      jQuery(form).attr('action', s.url);
      jQuery(form).attr('method', 'POST');
      jQuery(form).attr('target', frameId);
      if (form.encoding) {
        jQuery(form).attr('encoding', 'multipart/form-data');
      } else {
        jQuery(form).attr('enctype', 'multipart/form-data');
      }
      jQuery(form).submit();
    } catch (e) {
      jQuery.handleError(s, xml, null, e);
    }
    jQuery('#' + frameId).load(uploadCallback);
    return {
      abort: function () {
      }
    };
  },
  uploadHttpData: function (r, type) {
    var data = !type;
    data = type == "xml" || data ? r.responseXML : r.responseText;
    // If the type is "script", eval it in global context
    if (type == "script")
      jQuery.globalEval(data);
    // Get the JavaScript object, if JSON is used.
    if (type == "json")
      eval("data = " + data);
    // evaluate scripts within html
    if (type == "html")
      jQuery("<div>").html(data).evalScripts();
    return data;
  }, handleError: function (s, xhr, status, e) {
    // If a local callback was specified, fire it
    if (s.error)
      s.error(xhr, status, e);
    // If we have some XML response text (e.g. from an AJAX call) then log it in the console
    else if (xhr.responseText)
      console.log(xhr.responseText);
  }
})
```
