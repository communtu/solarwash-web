(function(){var e={}.hasOwnProperty,t=function(t,n){function i(){this.constructor=t}for(var r in n)e.call(n,r)&&(t[r]=n[r]);return i.prototype=n.prototype,t.prototype=new i,t.__super__=n.prototype,t};window.AA.TableCheckboxToggler=AA.TableCheckboxToggler=function(e){function n(){n.__super__.constructor.apply(this,arguments)}return t(n,e),n.prototype._init=function(){return n.__super__._init.apply(this,arguments)},n.prototype._bind=function(){var e=this;return n.__super__._bind.apply(this,arguments),this.$container.find("tbody").find("td").bind("click",function(t){if(t.target.type!=="checkbox")return e._didClickCell(t.target)})},n.prototype._didChangeCheckbox=function(e){var t;return n.__super__._didChangeCheckbox.apply(this,arguments),t=$(e).parents("tr"),e.checked?t.addClass("selected"):t.removeClass("selected")},n.prototype._didClickCell=function(e){return $(e).parent("tr").find(":checkbox").click()},n}(AA.CheckboxToggler),function(e){return e.widget.bridge("tableCheckboxToggler",AA.TableCheckboxToggler)}(jQuery)}).call(this);