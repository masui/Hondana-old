//
// q = new IQAuth(id,iqpath)
//   e.g. IQAuth('abc','http://IQAuth.com')
//   (実際にはiqpath/db などのデータを参照)
// - q.setPasswordLength(8)
// - q.setPasswordCharacterSets('...','....')
// q.queryDiv()   // 認証画面のdivを生成
// q.composeDiv() // 問題画面のdivを生成
// q.success()  // 認証が成功かどうかを判断
// q.calcPassword() // 現在選択された答からパスワードを計算
//

//function IQAuthxxx(id,iqpath){
//  alert(id);
//}

function IQAuth(id,iqpath){
  this.id = id;
  this.iqpath = iqpath;

  //  データをサーバから取得すべき。データを取得できるまで待つ。
  //  取得できなければ失敗を返す。(認証不可状態)

  var d = $.ajax({
	  type: 'GET',
	  url: getdata,
	  async: false // 同期
  }).responseText;
  eval("d =" + this.ajaxFilter(d)); // JASON.parse(d) ?

  this.passhash = d[0];
  this.data = d[1];

  this.answerInit();

  // this.queryDisplay();

 this.pdigits = 8;
 // パスワードに使う文字種 Safariの不可解なバグ? 下のコメントが無いと動かない
 //  
 this.pchars = [
   'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXY',
   'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
 ];
 // データ追加のとき利用するサンプルデータ
 this.sample = [
   ["http://gyazo.com/86279eee75f2d3c3742ba1b664e7a477.png",
     '大崎公園', '披露山公園', '源氏山公園', 'しおさい公園', '城ヶ島公園'],
   ["http://gyazo.com/669c1af6b8132e5e54bf80b90cf8c0bd.png",
     '真鶴', '逗子', '熱海', '下田', '伊東'],
   ["http://gyazo.com/a9241803acf7b4ff3767f17eecdd283d.png",
     '増井', '小池',  '高田',  '山田',  '田中'],
   ["http://gyazo.com/347e95389984ea592c35992160b65297.png",
     '九品寺', '妙本寺', '安国論寺', '光明寺', '浄智寺'],
   ["http://gyazo.com/52b6c59767f271248615324ff927a33e.png",
     '千石', '千駄木', '駒込', '根津', '日暮里'],
 ];
}

IQAuth.prototype.ajaxFilter = function(t){
  if(navigator.appVersion.indexOf( "KHTML" ) > -1){
    // Safariの文字化け対策
    // http://la.ma.la/blog/diary_200609220110.htm
    var esc = escape(t);
    return(esc.indexOf("%u") < 0 && esc.indexOf("%") > -1) ? decodeURIComponent(esc) : t
  }
  else {
    return t;
  }
};

IQAuth.prototype.answerInit = function(){
  var i;
  this.answer = [];
  for(i=0;i<this.data.length;i++){
    this.answer[i] = 0;
  }  
}

IQAuth.prototype.setPasswordLength = function(len){
  this.pdigits = len;
}

IQAuth.prototype.setPasswordCharacterSets = function(sets){
  this.pchars = sets;
}

IQAuth.prototype.calcPassword = function(){
  var i;
  var str = '';
  for(i=0;i<this.data.length;i++){
    str += this.data[i][0];
    str += this.data[i][this.answer[i]+1];
  }

  var md5 = MD5_hexhash(str);

  var pass = '';
  for(i=0;i<this.pdigits;i++){
    var hexstr = md5.substring(i*4,i*4+4);
    var v = parseInt(hexstr,16);
    var p = this.pchars[i >= this.pchars.length ? this.pchars.length-1 : i];
    ///pass += p[v % p.length]; IEで動かない!
    pass += p.substr(v % p.length,1);
  }

  return pass;
}

IQAuth.prototype.eventId = function(event){ // private
  var element = event.target || window.event.srcElement;
  return element.id

//  if(document.all){
//    return window.event.srcElement.id;
//  }
//  else {
//    return event.target.id;
//  }
}

IQAuth.prototype.answerClick = function(event){
  var element = event.target || event.srcElement;
  var iqauth = element.iqauth;
  var m = iqauth.eventId(event).match(/(.)(.)/);
  var q = Number(m[1]);
  var a = Number(m[2]);
  iqauth.answer[q] = a;
  iqauth.queryDisplay();
}

IQAuth.prototype.queryAnswerSpan = function(i,j){
  var span = document.createElement('span');
  span.id = String(i) + String(j);
  span.style.fontSize = '9pt';
  span.style.padding = '1pt';
  span.style.fontFamily = 'sans-serif';
  span.innerHTML = this.data[i][j+1];
  span.kind = 'text';

//  span.addEventListener('click',xxx,true); IEで動かない

//  span.addEventListener('mousedown',function(event){
//    var element = event.target || event.srcElement;
//    element.iqauth.answerClick(event);
//    },true);

  span.onmousedown = function(event){
    var element;
    if(document.all){
      event = window.event;
      element = window.event.srcElement;
    }
    else element = event.target
    element.iqauth.answerClick(event);
  }
  span.iqauth = this;
  return span;
}

IQAuth.prototype.queryDiv = function(){ // 認証画面用のdiv
  var i,j;
  var div = document.createElement('div');
  div.id = 'whole';
  for(i=0;i<this.data.length;i++){
    var img = document.createElement('img');
    img.src = this.data[i][0];
    img.style.height = '100px';
    img.style.width = '120px';
    img.style.cssFloat = 'left';
    img.style.styleFloat = 'left';
    img.id = 'image' + i;
    div.appendChild(img);
    var div2 = document.createElement('div');
    div2.style.cssFloat = 'left';
    div2.style.styleFloat = 'left';
    div2.style.padding = 5;
    div2.id = 'ansdiv' + String(i);
    div.appendChild(div2);
    for(j=0;j<this.data[i].length-1;j++){
      div2.appendChild(this.queryAnswerSpan(i,j));
      div2.appendChild(document.createElement('br'));
    }
    var br = document.createElement('br');
    br.clear = 'all';
    div.appendChild(br);
  }
  return div;
}

IQAuth.prototype.queryDisplay = function(){ // 認証画面を再表示
  var i,j;
  for(i=0;i<this.data.length;i++){
    var div = document.getElementById(String(i));
    for(j=0;j<this.data[i].length-1;j++){
      var id = String(i) + String(j);
      var e = document.getElementById(id);
      if(this.answer[i] == j){
        e.style.color = '#ffffff';
        e.style.backgroundColor = '#008800';
      }
      else {
        e.style.color = '#000000';
        e.style.backgroundColor = '#ffffff';
      }
    }
  }
}

IQAuth.prototype.composeAnswerSpan = function(i,j){
  var span = document.createElement('div');
  span.id = String(i) + String(j);
  span.style.fontSize = '9pt';
  span.style.fontFamily = 'sans-serif';
  span.style.border = 'solid';
  span.style.borderWidth = '1px';
  span.style.padding = '1';
  span.style.margin = '0 0 2 2';
  span.style.verticalAlign = 'middle';
  span.innerHTML = this.data[i][j+1];
  span.kind = 'text';
  span.iqauth = this;
  span.onmousedown = function(event){
    var element = event.target || event.srcElement;
    var iqauth = element.iqauth;
    var m = iqauth.eventId(event).match(/(.)(.)/);
    var q = Number(m[1]);
    var a = Number(m[2]);
    iqauth.answer[q] = a;
    iqauth.setEditline(event);
    iqauth.composeDisplay();
  };
  span.iqauth = this;
  return span;
}

IQAuth.prototype.imageSpan = function(i){
  var span = document.createElement('div');
  span.id = 'imageurl' + String(i);
  span.style.backgroundColor = 'white';
  span.style.fontSize = '9pt';
  span.style.fontFamily = 'sans-serif';
  span.style.border = 'solid';
  span.style.borderWidth = '1px';
  span.style.padding = 1;
  span.style.margin = '0 0 2 2';
  span.style.verticalAlign = 'middle';
  span.innerHTML = this.data[i][0];
  span.kind = 'text';
  span.iqauth = this;
  span.onmousedown = function(event){
    var element = event.target || event.srcElement;
    var iqauth = element.iqauth;
    iqauth.setEditline(event);
    iqauth.composeDisplay();
  };
  return span;
}

IQAuth.prototype.oneQuestion = function(div1,i){
  div1.appendChild(this.imageSpan(i));

  var img = document.createElement('img');
  img.src = this.data[i][0];
  img.style.height = 100;
  img.style.cssFloat = 'left';
  img.style.styleFloat = 'left';
  img.style.padding = 2;
  img.id = "image" + i;

  div1.appendChild(img);
  var div2 = document.createElement('div');
  div2.style.cssFloat = 'left';
  div2.style.styleFloat = 'left';
  div2.style.padding = 0;
  div2.id = 'ansdiv' + String(i);
  for(j=0;j<this.data[i].length-1;j++){
    div2.appendChild(this.composeAnswerSpan(i,j));
  }
  ////
  var plus = document.createElement('span');
  plus.innerHTML = '＋';
  plus.id = 'aplus' + String(i);
  plus.className = 'floatbutton';
  plus.iqauth = this;
  plus.onmousedown = function(event){
    var element = event.target || event.srcElement;
    var iqauth = element.iqauth;
    var m = iqauth.eventId(event).match(/aplus(.*)$/);
    var n = Number(m[1]);
    iqauth.data[n].push('新しい回答例');
    var e = document.getElementById('ansdiv'+n);
    var minus = e.lastChild;
    e.removeChild(minus);
    var plus = e.lastChild;
    e.removeChild(plus);
    e.appendChild(iqauth.composeAnswerSpan(n,iqauth.data[n].length-1-1));
    e.appendChild(plus);
    e.appendChild(minus);
    iqauth.composeDisplay();
  }
  div2.appendChild(plus);

  ////
  var minus = document.createElement('span');
  minus.innerHTML = '−';
  minus.id = 'aminus' + String(i);
  minus.className = 'floatbutton';
  minus.iqauth = this;
  minus.onmousedown = function(event){
    var element = event.target || event.srcElement;
    var iqauth = element.iqauth;
    var m = iqauth.eventId(event).match(/aminus(.*)$/);
    var n = Number(m[1]);
    if(iqauth.data[n].length > 1){
      iqauth.data[n].pop();
      var e = document.getElementById('ansdiv'+n);
      var minus = e.lastChild;
      e.removeChild(minus);
      var plus = e.lastChild;
      e.removeChild(plus);
      e.removeChild(e.lastChild);
      e.appendChild(plus);
      e.appendChild(minus);
      iqauth.answer[n] = 0;
      iqauth.composeDisplay();
    }
  }
  div2.appendChild(minus);

  div1.appendChild(div2);
  var br = document.createElement('br');
  br.clear = 'all';
  div1.appendChild(br);
  div1.appendChild(document.createElement('p'));
}

IQAuth.prototype.composeDiv = function(){
  var i;
  var div1 = document.createElement('div');
  div1.id = 'whole';
  div1.style.backgroundColor = '#f0f0ff';
  for(i=0;i<this.data.length;i++){
    this.oneQuestion(div1,i);
  }
  var plus = document.createElement('span');
  plus.innerHTML = '＋';
  plus.id = 'qplus' + String(i);
  plus.className = 'floatbutton';
  plus.iqauth = this;
  plus.onmousedown = function(event){
    var element = event.target || event.srcElement;
    var iqauth = element.iqauth;
    var n = iqauth.data.length;
    iqauth.data.push(iqauth.sample[n]);
    var e = document.getElementById('whole');
    var minus = e.lastChild;
    e.removeChild(minus);
    var plus = e.lastChild;
    e.removeChild(plus);
    iqauth.oneQuestion(e,iqauth.data.length-1);
    e.appendChild(plus);
    e.appendChild(minus);
    iqauth.composeDisplay();
    return false;
  }
  div1.appendChild(plus);

  var minus = document.createElement('span');
  minus.innerHTML = '−';
  minus.id = 'qminus' + String(i);
  minus.className = 'floatbutton';
  minus.iqauth = this;
  minus.onmousedown = function(event){
    var element = event.target || event.srcElement;
    var iqauth = element.iqauth;
    if(iqauth.data.length > 0){
      iqauth.data.pop();
      var e = document.getElementById('whole');
      var minus = e.lastChild;
      e.removeChild(minus);
      var plus = e.lastChild;
      e.removeChild(plus);
      e.removeChild(e.lastChild);
      e.removeChild(e.lastChild);
      e.removeChild(e.lastChild);
      e.removeChild(e.lastChild);
      e.removeChild(e.lastChild);
      e.appendChild(plus);
      e.appendChild(minus);
      iqauth.composeDisplay();
    }
    return false;
  }
  div1.appendChild(minus);

  for(i=0;i<this.data.length;i++){
    this.answer[i] = 0;
  }

  return div1;
}

IQAuth.prototype.inputArea = function(id,size){
  var div = document.createElement('div');
  div.style.border = 'none';
  div.style.borderWidth = 0;
  div.style.padding = 0;
  div.style.margin = 0;
  
  var input = document.createElement('input');
  input.type = 'text';
  input.iqauth = this;
  input.onmousedown = function(event){
    var element = event.target || event.srcElement;
    element.iqauth.setEditline(event);
  }
  input.autocomplete = 'off';
  input.style.border = 'solid';
  input.style.borderWidth = '1px';
  input.style.padding = 1;
  input.style.margin = '0 0 2 2';
  input.style.verticalAlign = 'middle';
  input.style.backgroundColor = '#ffffff';
  input.style.fontSize = '9pt';
  input.style.fontFamily = 'sans-serif';
  input.size = size;
  input.kind = 'input';

  div.id = id;
  div.appendChild(input);
  div.kind = 'input';
  return div;
}

//
// mousedown / eid / editidのロジックを書いておくこと
//

IQAuth.prototype.setEditline = function(event){
  this.editid = this.eventId(event);
}

IQAuth.prototype.composeDisplay = function(){
  var i,j;
  var parent;
  parent = document.getElementById('whole');
  for(i=0;i<this.data.length;i++){
    var id = 'imageurl' + String(i);
    var e = document.getElementById(id);
    if(e.kind == 'input'){
      if(this.editid == id){
        // do nothing
      }
      else {
        if(this.editid != ''){
          this.data[i][0] = e.firstChild.value;
          var span = this.imageSpan(i);
          parent.replaceChild(span,e);
          document.getElementById('image'+i).src = e.firstChild.value;
        }
      }
    }
    else {
      if(this.editid == id){
        var input = this.inputArea(id,90);
        input.firstChild.value = this.data[i][0];
        parent.replaceChild(input,e);
      }
    }
  }

  for(i=0;i<this.data.length;i++){
    parent = document.getElementById('ansdiv' + String(i));
    for(j=0;j<this.data[i].length-1;j++){
      var id = String(i) + String(j);
      var e = document.getElementById(id);
      if(e.kind == 'input'){
        if(this.editid == id){
          // do nothing
        }
        else {
          if(this.editid != ''){
            this.data[i][j+1] = e.firstChild.value;
            var span = this.composeAnswerSpan(i,j);
            parent.replaceChild(span,e);
          }
        }
      }
      else { // text
        if(this.editid == id){
          var input = this.inputArea(id,30);
          input.firstChild.value = this.data[i][j+1];
          parent.replaceChild(input,e);
        }
      }
    }
  }
  for(i=0;i<this.data.length;i++){
    var div = document.getElementById(String(i));
    for(j=0;j<this.data[i].length-1;j++){
      var id = String(i) + String(j);
      var e = document.getElementById(id);
      if(e.kind == 'text'){
        if(this.answer[i] == j){
          e.style.backgroundColor = '#ffffff';
        }
        else {
          e.style.backgroundColor = '#e0e0e0';
        }
      }
    }
  }
}

IQAuth.prototype.success = function(){
  var password = this.calcPassword();
  var hash = MD5_hexhash(password);
  return hash == this.passhash
}


