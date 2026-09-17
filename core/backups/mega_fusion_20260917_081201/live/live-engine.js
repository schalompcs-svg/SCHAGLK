const state={running:false,logs:[]};

function start(){state.running=true;log("LIVE started");}
function stop(){state.running=false;log("LIVE stopped");}
function log(x){state.logs.push(String(x));}

function executeHTML(html){
  if(typeof html!=="string") throw new Error("HTML invalide");
  start();
  return {
    type:"html",
    content:html,
    interactive:true,
    logs:state.logs.slice()
  };
}

module.exports={start,stop,log,executeHTML,state};
