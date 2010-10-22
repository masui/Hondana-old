// http://www.fromdfj.net/javascript/cookie.html の方法をコピー

function loadCookie(arg){ //argはデータ識別文字列
  if(arg){
     var cookieData = document.cookie + ';'; //文字列の最後に「;」を追加
     var startPoint1 = cookieData.indexOf(arg);
     var startPoint2 = cookieData.indexOf('=',startPoint1);
     var endPoint = cookieData.indexOf(';',startPoint1);
     if(startPoint2 < endPoint && startPoint1 > -1){
       cookieData = cookieData.substring(startPoint2+1,endPoint); // こうしないと'='が入ってしまうのだが...?
       cookieData = cookieData;
       return cookieData;
     }
  }
  return false;
}

//
// リファラが存在する場合(リンクから飛んできた場合)は何もしない
// 存在する場合はCookieのShelfDirで定義された本棚に飛んでしまう。
//
shelfdir = loadCookie('ShelfDir');
//alert(shelfdir);

//alert(document.cookie);
//alert(shelfdir);

if(!document.referrer && shelfdir){
  location.href = "http://hondana.org/" + shelfdir;
}
