layout: post
category: 前端
title:  "jquery-form插件的使用"
tag: [web, js]
excerpt: 用于阻止浏览器提交表单并进行异步提交。
---

## 介绍

用于阻止浏览器提交表单并进行异步提交。

```html
$('#formLogin').on("submit",function() {
  $(this).ajaxSubmit(
    {
      //url: url,                 //默认是form的action
      //type: type,               //默认是form的method（get or post）
      //dataType: "json",           //html(默认), xml, script, json...接受服务端返回的类型
      //clearForm: true,          //成功提交后，清除所有表单元素的值
      //resetForm: true,          //成功提交后，重置所有表单元素的值
      target: '#output',          //把服务器返回的内容放入id为output的元素中
      //timeout: 3000,               //限制请求的时间，当请求大于3秒后，跳出请求
      //提交前的回调函数
      beforeSubmit: function(arr,$form,options){
        //formData: 数组对象，提交表单时，Form插件会以Ajax方式自动提交这些数据，格式如：[{name:user,value:val },{name:pwd,value:pwd}]
        //jqForm:   jQuery对象，封装了表单的元素
        //options:  options对象
        //比如可以再表单提交前进行表单验证
        console.log("beforeSubmit",arr,$form,options)
      },
      //提交成功后的回调函数
      success: function(data,status,xhr,$form){
        console.log("success",data,status,xhr,$form);
        if(data.Flag){
          console.log(data.Content)
        }
      },
      error: function(xhr, status, error, $form){
        console.log("error",xhr, status, error, $form)
      },
      complete: function(xhr, status, $form){
        console.log("complete",xhr, status, $form)
      }
    }
  );
  return false; //阻止表单默认提交
});
```
