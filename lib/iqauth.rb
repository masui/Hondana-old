# -*- coding: utf-8 -*-
# -*- ruby -*-
#
# 本棚における画像なぞなぞ認証実行JavaScriptを生成する
#

def iqauth_js(shelf,book,entry)
  categories = entry.categories.to_s.gsub(/'/,"\\\\'")
  score = entry.score.to_s.gsub(/'/,"\\\\'")
  comment = entry.comment.to_s.gsub(/'/,"\\\\'").gsub(/[\r\n]+/,"\\\\n\\\\\n")

  # iqpath = url_for :controller => 'iqauth', :action => 'getdata', :id => shelf.id
  iqpath = "/iqauth"

  <<EOF
<script type="text/javascript">
// 可変部分... Rubyが書く値
var shelf = '#{shelf.name}';
var id = '#{shelf.id}';
var isbn = '#{book.isbn}';
var categories = '#{categories}';
var score = '#{score}';
var comment = '#{comment}';
var usequiz = #{shelf.use_iqauth.to_i > 0 ? 'true' : 'false'};

var iqpath = '#{iqpath}';
var id = '#{shelf.id}';

// 以下は大体固定部分
var authorized = false;
var timeout;
var q;

if (window.ActiveXObject && !window.XMLHttpRequest) {
  window.XMLHttpRequest = function() {
    return new ActiveXObject((navigator.userAgent.toLowerCase().indexOf('msie 5') != -1) ? 'Microsoft.XMLHTTP' : 'Msxml2.XMLHTTP');
  };
}

window.onload = function(){
  if(usequiz){
    showquiz();
  }
  else {
    showform();
  }
}

function showquiz(){
  var div;
  //q = new IQAuth(id,"http://www.hondana.org/ImageAuth");
  //q = new IQAuth(id,"../..");
  //q = new IQAuth(id,"#{RAILS_ROOT}");
  //q = new IQAuth(id,getdata);
  q = new IQAuth(id,iqpath);
  div = document.getElementById('td00');
  div.innerHTML = '認　　証';
  div.vAlign = 'top';
  div = document.getElementById('td01');
  div.appendChild(q.queryDiv());
  q.queryDisplay();

  var del = document.getElementById('deleteform');
  del.style.visibility = 'hidden';
}

function showform(){
  var td, input;
  td  = document.getElementById('td01');
  if(td.firstChild){
    td.removeChild(td.firstChild);
  }
  input = document.createElement('input');
  input.value = categories;
  input.name = 'entry[categories]';
  td.appendChild(input);
  //s = document.createElement('span');
  //s.value = 'e.g. 科学, 購入検討';
  //td.appendChild(s);

  td = document.getElementById('td00');
  td.innerHTML = 'カテゴリ';

  td  = document.getElementById('td11');
  input = document.createElement('input');
  input.value = score;
  input.name = 'entry[score]';
  td.appendChild(input);
  td = document.getElementById('td10');
  td.innerHTML = '評　　価';

  td  = document.getElementById('td21');
  input = document.createElement('textarea');
  input.value = comment;
  input.name = 'entry[comment]';
  // input.wrap = 'virtual'; ?? IE6でエラーになる
  input.rows = '10';
  input.cols = '70';
  td.appendChild(input);
  td = document.getElementById('td20');
  td.vAlign = 'top';
  td.innerHTML = 'コメント';

  td  = document.getElementById('td31');
  input = document.createElement('input');
  input.type = 'submit'
  input.value = '更新';
  td.appendChild(input);

  //pass = document.getElementById('password');
  //pass.value = q.calcPassword();

  var del = document.getElementById('deleteform');
  del.style.visibility = 'visible';
}

function checkauth(){
  if(usequiz){
    authorized = q.success();
    if(authorized){
      showform();
    }
  }
}

</script>
EOF
end
