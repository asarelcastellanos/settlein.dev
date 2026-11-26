(function(){
class DCLogic{constructor(p){this.props=p||{};this.state={}}setState(u){Object.assign(this.state,typeof u==='function'?u(this.state,this.props):u);schedule()}componentDidMount(){}}
window.DCLogic=DCLogic;
let host,tpl,comp,pending=false;
const fnCache={};
function ev(expr,scope){const k=expr;let f=fnCache[k];if(!f){f=fnCache[k]=new Function('s','with(s){return ('+expr+')}')}try{return f(scope)}catch(e){console.warn('hole',expr,e.message);return ''}}
const RX=/\{\{([\s\S]*?)\}\}/g;
function interp(str,scope){return str.replace(RX,(m,e)=>{const v=ev(e,scope);return v==null||v===false?'':String(v)})}
function single(str){const m=str.match(/^\s*\{\{([\s\S]*?)\}\}\s*$/);return m?m[1]:null}
function proc(node,scope,out){
  for(const ch of Array.from(node.childNodes)){
    if(ch.nodeType===3){out.appendChild(document.createTextNode(ch.data.includes('{{')?interp(ch.data,scope):ch.data));continue}
    if(ch.nodeType!==1)continue;
    const tag=ch.tagName.toLowerCase();
    if(tag==='sc-for'){const list=ev(single(ch.getAttribute('list')),scope)||[];const as=ch.getAttribute('as')||'item';list.forEach((it,i)=>{const sc=Object.create(scope);sc[as]=it;sc.$index=i;proc(ch,sc,out)});continue}
    if(tag==='sc-if'){if(ev(single(ch.getAttribute('value')),scope))proc(ch,scope,out);continue}
    const el=ch.namespaceURI==='http://www.w3.org/2000/svg'?document.createElementNS(ch.namespaceURI,ch.tagName):document.createElement(ch.tagName);
    for(const a of Array.from(ch.attributes)){
      const v=a.value,s=v.includes('{{')?single(v):null;
      if(/^on[A-Z]/.test(a.name)||/^on/.test(a.name)&&s){const fn=s?ev(s,scope):null;if(typeof fn==='function'){let n=a.name.slice(2).toLowerCase();el.addEventListener(n,fn)}continue}
      if(s!==null){const val=ev(s,scope);if(val===false||val==null)continue;if(val===true){el.setAttribute(a.name,'');continue}
        if(a.name==='style'&&typeof val==='object'){Object.assign(el.style,val);continue}
        el.setAttribute(a.name,String(val));if(a.name==='checked')el.checked=true;continue}
      el.setAttribute(a.name,v.includes('{{')?interp(v,scope):v);
    }
    if(tag==='input'&&!el.hasAttribute('checked'))el.checked=false;
    proc(tag==='template'?ch.content:ch,scope,el);out.appendChild(el);
  }
}
function render(){pending=false;const vals=comp.renderVals?comp.renderVals():{};const frag=document.createDocumentFragment();proc(tpl.content,Object.assign(Object.create(null),vals),frag);host.replaceChildren(frag)}
function schedule(){if(!comp||pending)return;pending=true;Promise.resolve().then(render)}
window.addEventListener('DOMContentLoaded',()=>{
  host=document.querySelector('x-dc');const raw=host.innerHTML;
  tpl=document.createElement('template');tpl.innerHTML=raw;
  const hel=tpl.content.querySelector('helmet');if(hel){for(const c of Array.from(hel.childNodes)){if(c.nodeType===1){const n=document.createElement(c.tagName);for(const a of c.attributes)n.setAttribute(a.name,a.value);n.textContent=c.textContent;document.head.appendChild(n)}}hel.remove()}
  host.innerHTML='';host.style.display='block';
  const sc=document.querySelector('script[data-dc-script]');let props={};
  try{const d=JSON.parse(sc.getAttribute('data-props')||'{}');for(const k in d){if(k[0]==='$')continue;props[k]=d[k]&&typeof d[k]==='object'&&'default' in d[k]?d[k].default:d[k]}}catch(e){}
  const q=new URLSearchParams(location.search);for(const [k,v] of q){props[k]=v==='true'?true:v==='false'?false:v}
  const C=new Function('DCLogic',sc.textContent+';return Component;')(DCLogic);
  comp=new C(props);if(!comp.props||!Object.keys(comp.props).length)comp.props=props;
  window.__dc=comp;render();comp.componentDidMount&&comp.componentDidMount();window.__dcReady=true;
});
})();
